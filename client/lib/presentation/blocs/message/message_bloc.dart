import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/reaction/reaction_model.dart';
import 'package:sigmail_client/domain/use_cases/chat/get_chat_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/send_message_use_case.dart';
import 'package:sigmail_client/domain/use_cases/message/add_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/message/remove_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/mark_messages_as_read_use_case.dart';
import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_request_model.dart';
import 'package:sigmail_client/data/models/attachment/create_message_with_attachment_client_dto.dart';
import 'package:sigmail_client/domain/use_cases/attachment/get_presigned_upload_url_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/upload_file_to_s3_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/send_message_with_attachment_use_case.dart';
import 'package:sigmail_client/presentation/blocs/message/message_event.dart';
import 'package:sigmail_client/presentation/blocs/message/message_state.dart';
import 'package:flutter/foundation.dart'; // Для kDebugMode и print
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

const int _defaultPageSize = 20; // Количество сообщений на страницу

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ObserveMessagesUseCase _observeMessagesUseCase;
  final GetPresignedUploadUrlUseCase _getPresignedUploadUrlUseCase;
  final UploadFileToS3UseCase _uploadFileToS3UseCase;
  final SendMessageWithAttachmentUseCase _sendMessageWithAttachmentUseCase;
  final AddReactionUseCase _addReactionUseCase;
  final RemoveReactionUseCase _removeReactionUseCase;
  final MarkMessagesAsReadUseCase _markMessagesAsReadUseCase;
  final ChatRepository _chatRepository;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _reactionUpdateSubscription;
  final String _chatId;

  MessageBloc({
    required String chatId,
    required GetChatMessagesUseCase getChatMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required ObserveMessagesUseCase observeMessagesUseCase,
    required GetPresignedUploadUrlUseCase getPresignedUploadUrlUseCase,
    required UploadFileToS3UseCase uploadFileToS3UseCase,
    required SendMessageWithAttachmentUseCase sendMessageWithAttachmentUseCase,
    required AddReactionUseCase addReactionUseCase,
    required RemoveReactionUseCase removeReactionUseCase,
    required MarkMessagesAsReadUseCase markMessagesAsReadUseCase,
    required ChatRepository chatRepository,
  })  : _chatId = chatId,
        _getChatMessagesUseCase = getChatMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _observeMessagesUseCase = observeMessagesUseCase,
        _getPresignedUploadUrlUseCase = getPresignedUploadUrlUseCase,
        _uploadFileToS3UseCase = uploadFileToS3UseCase,
        _sendMessageWithAttachmentUseCase = sendMessageWithAttachmentUseCase,
        _addReactionUseCase = addReactionUseCase,
        _removeReactionUseCase = removeReactionUseCase,
        _markMessagesAsReadUseCase = markMessagesAsReadUseCase,
        _chatRepository = chatRepository,
        super(MessageInitial()) {
    if (kDebugMode) {
      print('[MessageBloc] Initializing for chat ID: $_chatId');
    }
    on<LoadMessages>(_onLoadMessages);
    on<InternalMessageReceived>(_onInternalMessageReceived);
    on<SendNewMessage>(_onSendNewMessage);
    on<SendAttachmentEvent>(_onSendAttachment);
    on<AddReactionRequested>(_onAddReactionRequested);
    on<RemoveReactionRequested>(_onRemoveReactionRequested);
    on<InternalReactionsUpdated>(_onInternalReactionsUpdated);

    // Начинаем слушать новые сообщения сразу при создании блока
    _subscribeToMessages();
    _subscribeToReactionUpdates();
  }

  void _subscribeToMessages() {
    if (kDebugMode) {
      print('[MessageBloc] Subscribing to messages for chat ID: $_chatId');
    }
    _messageSubscription?.cancel();
    _messageSubscription = _observeMessagesUseCase
        .call(ObserveMessagesParams(_chatId))
        .listen((message) {
      if (kDebugMode) {
        print('[MessageBloc] Received message via stream: ${message.id}, text: ${message.text}');
      }
      add(InternalMessageReceived(message));
    }, onError: (error) {
      if (kDebugMode) {
        print('[MessageBloc] Error observing messages: $error');
      }
      // addError(error); // Это может быть полезно для отладки, но не генерирует состояние Error
    });
  }

  void _subscribeToReactionUpdates() {
    if (kDebugMode) {
      print('[MessageBloc] Subscribing to reaction updates for chat ID: $_chatId');
    }
    _reactionUpdateSubscription?.cancel();
    _reactionUpdateSubscription = _chatRepository
        .observeMessageReactionsUpdate(_chatId)
        .listen((reactionUpdateMap) {
      // reactionUpdateMap это Map<String, List<ReactionModel>>
      // Ключ - messageId, значение - список реакций
      reactionUpdateMap.forEach((messageId, reactions) {
        if (kDebugMode) {
          print('[MessageBloc] Received reaction update via stream for message $messageId. Reactions count: ${reactions.length}');
        }
        add(InternalReactionsUpdated(messageId: messageId, reactions: reactions));
      });
    }, onError: (error) {
      if (kDebugMode) {
        print('[MessageBloc] Error observing reaction updates: $error');
      }
    });
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<MessageState> emit) async {
    if (kDebugMode) {
      print('[MessageBloc] Event: LoadMessages, page: ${event.pageNumber}');
    }
    final currentState = state;
    if (event.pageNumber == 1) {
      emit(MessageLoading());
      if (kDebugMode) print('[MessageBloc] State: MessageLoading');
    } else if (currentState is MessageLoaded && currentState.hasReachedMax) {
      if (kDebugMode) print('[MessageBloc] LoadMessages: Already reached max, returning.');
      return; // Уже загружены все сообщения
    }

    try {
      final result = await _getChatMessagesUseCase.call(
        GetChatMessagesParams(
          chatId: event.chatId,
          pageNumber: event.pageNumber,
          pageSize: event.pageSize,
        ),
      );
      result.fold(
        (failure) {
          emit(MessageError(failure.message));
          if (kDebugMode) print('[MessageBloc] State: MessageError - ${failure.message}');
        },
        (newMessages) {
          if (kDebugMode) print('[MessageBloc] Loaded ${newMessages.length} messages from API.');
          
          // Если это первая страница и сообщения загружены, помечаем их как прочитанные
          if (event.pageNumber == 1 && newMessages.isNotEmpty) {
            // Вызываем use case, не дожидаясь результата, чтобы не блокировать UI
            _markMessagesAsReadUseCase.call(MarkMessagesAsReadParams(_chatId)).then((result) {
              result.fold(
                (failure) => print('[MessageBloc] Failed to mark messages as read: ${failure.message}'),
                (_) => print('[MessageBloc] Messages marked as read successfully for chat $_chatId')
              );
            });
          }

          if (currentState is MessageLoaded && event.pageNumber > 1) {
            emit(newMessages.isEmpty
                ? currentState.copyWith(hasReachedMax: true)
                : MessageLoaded(
                    currentState.messages + newMessages,
                    hasReachedMax: newMessages.length < event.pageSize,
                  ));
             if (kDebugMode) print('[MessageBloc] State: MessageLoaded (paginated), total: ${currentState.messages.length + newMessages.length}, hasReachedMax: ${newMessages.isEmpty || newMessages.length < event.pageSize}');
          } else {
            emit(MessageLoaded(
              newMessages,
              hasReachedMax: newMessages.length < event.pageSize,
            ));
            if (kDebugMode) print('[MessageBloc] State: MessageLoaded (initial), total: ${newMessages.length}, hasReachedMax: ${newMessages.length < event.pageSize}');
          }
        },
      );
    } catch (e) {
      emit(MessageError('Ошибка загрузки сообщений: ${e.toString()}'));
      if (kDebugMode) print('[MessageBloc] State: MessageError - ${e.toString()}');
    }
  }

  void _onInternalMessageReceived(
      InternalMessageReceived event, Emitter<MessageState> emit) {
    if (kDebugMode) {
        print('[MessageBloc] Event: InternalMessageReceived, message ID: ${event.message.id}, text: ${event.message.text}');
    }
    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;
      final updatedMessages = currentState.messages.where((m) => m.id != event.message.id).toList();
      updatedMessages.insert(0, event.message);
      
      emit(MessageLoaded(updatedMessages, hasReachedMax: currentState.hasReachedMax));
      if (kDebugMode) print('[MessageBloc] State: MessageLoaded (after internal receive), total: ${updatedMessages.length}');
    } else if (state is MessageSendingAttachment) {
        final currentState = state as MessageSendingAttachment;
        final updatedMessages = currentState.messages.where((m) => m.id != event.message.id).toList();
        updatedMessages.insert(0, event.message);
        emit(MessageLoaded(updatedMessages, hasReachedMax: currentState.hasReachedMax));
        if (kDebugMode) print('[MessageBloc] State: MessageLoaded (from MessageSendingAttachment after internal receive), total: ${updatedMessages.length}');
    } else {
      if (kDebugMode) {
        print('[MessageBloc] State is not MessageLoaded (${state.runtimeType}) when InternalMessageReceived. Triggering LoadMessages.');
      }
      add(LoadMessages(_chatId)); 
    }
  }

  Future<void> _onSendNewMessage(
      SendNewMessage event, Emitter<MessageState> emit) async {
    if (kDebugMode) {
        print('[MessageBloc] Event: SendNewMessage, text: ${event.createMessageModel.text}');
    }
    final result = await _sendMessageUseCase.call(event.createMessageModel);
    result.fold(
      (failure) {
        emit(MessageError('Ошибка отправки: ${failure.message}'));
        if (kDebugMode) print('[MessageBloc] State: MessageError (send failed) - ${failure.message}');
      },
      (sentMessage) {
        if (kDebugMode) {
            print('[MessageBloc] Message sent successfully via API: ${sentMessage.id}. Waiting for SignalR echo.');
        }
      },
    );
  }

  Future<void> _onSendAttachment(
    SendAttachmentEvent event, Emitter<MessageState> emit) async {
    if (kDebugMode) {
      print('[MessageBloc] Event: SendAttachmentEvent for chat ${event.chatId}, file: ${event.file.name}');
    }

    List<MessageModel> currentMessages = [];
    bool currentHasReachedMax = false;
    if (state is MessageLoaded) {
      final loadedState = state as MessageLoaded;
      currentMessages = loadedState.messages;
      currentHasReachedMax = loadedState.hasReachedMax;
    } else if (state is MessageSendingAttachment) { // Если уже отправляем что-то
      final sendingState = state as MessageSendingAttachment;
      currentMessages = sendingState.messages;
      currentHasReachedMax = sendingState.hasReachedMax;
    }
    // Всегда переходим в MessageSendingAttachment, чтобы показать индикатор для НОВОГО файла,
    // даже если предыдущий список уже был загружен.
    emit(MessageSendingAttachment(List.from(currentMessages), currentHasReachedMax)); // Используем копию списка
    if (kDebugMode) print('[MessageBloc] State: MessageSendingAttachment');

    try {
      final fileSize = await event.file.length();
      final fileName = event.file.name;
      final String? mimeType = lookupMimeType(fileName, headerBytes: await event.file.readAsBytes()); //TODO: optimize to not read whole file
      final String contentType = mimeType ?? 'application/octet-stream';

      if (kDebugMode) {
        print('[MessageBloc] File details: Name=$fileName, Size=$fileSize, ContentType=$contentType, AttachmentType=${event.attachmentType}');
      }
      
      // 1. Получить presigned URL от нашего бэкенда
      final presignedUrlResult = await _getPresignedUploadUrlUseCase.call(
        PresignedUrlRequestModel(
          fileName: fileName,
          fileSize: fileSize,
          contentType: contentType,
          attachmentType: event.attachmentType,
        ),
      );

      await presignedUrlResult.fold(
        (failure) async {
          throw Exception('Failed to get presigned URL: ${failure.message}');
        },
        (presignedUrlResponse) async {
          if (kDebugMode) {
            print('[MessageBloc] Got presigned URL: ${presignedUrlResponse.presignedUploadUrl}, FileKey: ${presignedUrlResponse.fileKey}');
          }

          // 2. Загрузить файл на S3 (MinIO)
          final uploadResult = await _uploadFileToS3UseCase.call(
            UploadFileToS3Params(
              presignedUrl: presignedUrlResponse.presignedUploadUrl, // Этот URL уже должен быть доступен извне (например, localhost:9000)
              file: event.file,
              contentType: contentType,
            ),
          );

          await uploadResult.fold(
            (failure) async {
              throw Exception('Failed to upload file to S3: ${failure.message}');
            },
            (_) async {
              if (kDebugMode) {
                print('[MessageBloc] File uploaded to S3 successfully. FileKey: ${presignedUrlResponse.fileKey}');
              }

              // 3. Отправить сообщение нашему бэкенду с информацией о вложении
              final messageDto = CreateMessageWithAttachmentClientDto(
                chatId: event.chatId,
                fileKey: presignedUrlResponse.fileKey,
                fileName: presignedUrlResponse.fileName,
                contentType: presignedUrlResponse.contentType ?? 'application/octet-stream',
                size: presignedUrlResponse.size,
                attachmentType: presignedUrlResponse.attachmentType,
                // Поля width, height, thumbnailKey пока null, бэкенд может их сам определить, если нужно
              );

              final sendMessageResult = await _sendMessageWithAttachmentUseCase.call(messageDto);

              sendMessageResult.fold(
                (failure) {
                  // Ошибка отправки сообщения бэкенду
                  if (kDebugMode) print('[MessageBloc] Error sending message with attachment to backend: ${failure.message}');
                  // Важно: не оставляем UI в состоянии MessageSendingAttachment навечно
                  emit(MessageError('Ошибка отправки сообщения с файлом: ${failure.message}'));
                },
                (sentMessage) {
                  if (kDebugMode) {
                    print('[MessageBloc] Message with attachment sent via API: ${sentMessage.id}. SignalR should deliver it to update UI.');
                  }
                  // НЕ ДЕЛАЕМ ЯВНЫЙ EMIT MessageLoaded ЗДЕСЬ.
                  // Полагаемся на то, что SignalR (_onInternalMessageReceived) обновит состояние.
                  // Если мы здесь сделаем emit(MessageLoaded(currentMessages...)), то можем затереть 
                  // сообщение, которое уже могло прийти по SignalR и обновить список.
                  // Просто выходим, индикатор загрузки уберется, когда SignalR обновит список 
                  // и переведет состояние в MessageLoaded.
                  // Если SignalR по какой-то причине не доставит сообщение, и мы остались в MessageSendingAttachment,
                  // это будет проблемой, но текущая логика на это не рассчитана.
                  // Основной поток - SignalR доставит.
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) print('[MessageBloc] Error in _onSendAttachment: $e');
      // Убедимся, что выходим из состояния загрузки в случае любой ошибки на верхнем уровне try-catch
      final String errorMessage = (e is Exception) ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      emit(MessageError('Ошибка при отправке вложения: $errorMessage'));
    }
  }

  Future<void> _onAddReactionRequested(
      AddReactionRequested event, Emitter<MessageState> emit) async {
    if (kDebugMode) {
      print('[MessageBloc] Event: AddReactionRequested for message ${event.messageId}, emoji: ${event.emoji}');
    }
    final result = await _addReactionUseCase.call(
      AddReactionParams(messageId: event.messageId, emoji: event.emoji),
    );

    result.fold(
      (failure) {
        // Можно показать ошибку пользователю через отдельное состояние или snackbar
        if (kDebugMode) print('[MessageBloc] Failed to add reaction: ${failure.message}');
        // Не меняем основное состояние сообщений, т.к. операция не удалась
      },
      (updatedReactions) {
        if (kDebugMode) print('[MessageBloc] Reaction added successfully via API. Reactions: $updatedReactions');
        // Обновляем состояние сообщения локально, чтобы UI сразу отразил изменение.
        // SignalR также пришлет обновление, но это для немедленной реакции UI.
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;
          final messageIndex = currentState.messages.indexWhere((m) => m.id == event.messageId);
          if (messageIndex != -1) {
            final updatedMessages = List<MessageModel>.from(currentState.messages);
            final oldMessage = updatedMessages[messageIndex];
            updatedMessages[messageIndex] = oldMessage.copyWith(reactions: updatedReactions);
            emit(MessageLoaded(updatedMessages, hasReachedMax: currentState.hasReachedMax));
             if (kDebugMode) print('[MessageBloc] State: MessageLoaded (after add reaction), total: ${updatedMessages.length}');
          }
        }
      },
    );
  }

  Future<void> _onRemoveReactionRequested(
      RemoveReactionRequested event, Emitter<MessageState> emit) async {
    if (kDebugMode) {
      print('[MessageBloc] Event: RemoveReactionRequested for message ${event.messageId}, emoji: ${event.emoji}');
    }
    final result = await _removeReactionUseCase.call(
      RemoveReactionParams(messageId: event.messageId, emoji: event.emoji),
    );

    result.fold(
      (failure) {
        if (kDebugMode) print('[MessageBloc] Failed to remove reaction: ${failure.message}');
      },
      (updatedReactions) {
        if (kDebugMode) print('[MessageBloc] Reaction removed successfully via API. Reactions: $updatedReactions');
        if (state is MessageLoaded) {
          final currentState = state as MessageLoaded;
          final messageIndex = currentState.messages.indexWhere((m) => m.id == event.messageId);
          if (messageIndex != -1) {
            final updatedMessages = List<MessageModel>.from(currentState.messages);
            final oldMessage = updatedMessages[messageIndex];
            updatedMessages[messageIndex] = oldMessage.copyWith(reactions: updatedReactions);
            emit(MessageLoaded(updatedMessages, hasReachedMax: currentState.hasReachedMax));
            if (kDebugMode) print('[MessageBloc] State: MessageLoaded (after remove reaction), total: ${updatedMessages.length}');
          }
        }
      },
    );
  }

  void _onInternalReactionsUpdated(
    InternalReactionsUpdated event, Emitter<MessageState> emit) {
    if (kDebugMode) {
      print('[MessageBloc] Event: InternalReactionsUpdated for message ${event.messageId}, reactions: ${event.reactions.length}');
    }
    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;
      final messageIndex = currentState.messages.indexWhere((m) => m.id == event.messageId);
      if (messageIndex != -1) {
        final updatedMessages = List<MessageModel>.from(currentState.messages);
        final oldMessage = updatedMessages[messageIndex];
        // Применяем реакции, пришедшие от SignalR
        updatedMessages[messageIndex] = oldMessage.copyWith(reactions: event.reactions);
        emit(MessageLoaded(updatedMessages, hasReachedMax: currentState.hasReachedMax));
        if (kDebugMode) print('[MessageBloc] State: MessageLoaded (after internal reactions update), total: ${updatedMessages.length}');
      } else {
         if (kDebugMode) print('[MessageBloc] Message ${event.messageId} not found in current state for reaction update.');
      }
    }
  }

  @override
  Future<void> close() {
    if (kDebugMode) {
      print('[MessageBloc] Closing for chat ID: $_chatId');
    }
    _messageSubscription?.cancel();
    _reactionUpdateSubscription?.cancel();
    // Добавляем вызов для закрытия соединения SignalR для этого чата
    // Важно: это должен быть неблокирующий вызов или обработанный с осторожностью,
    // чтобы не замедлить процесс закрытия блока.
    // _chatRepository.disconnectRealtimeForChat(_chatId) возвращает Future,
    // но здесь мы его не ждем (fire-and-forget), чтобы не блокировать super.close().
    // Это обычно безопасно для операций по очистке.
    _chatRepository.disconnectRealtimeForChat(_chatId);
    return super.close();
  }
} 