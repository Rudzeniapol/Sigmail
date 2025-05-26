import 'dart:async'; // Для Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/domain/use_cases/chat/get_chat_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/send_message_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/get_presigned_upload_url_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/upload_file_to_s3_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/send_message_with_attachment_use_case.dart';

// Для выбора файлов и работы с ними
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

import 'package:sigmail_client/presentation/blocs/message/message_bloc.dart';
import 'package:sigmail_client/presentation/blocs/message/message_event.dart';
import 'package:sigmail_client/presentation/blocs/message/message_state.dart';
import 'package:sigmail_client/presentation/bloc/typing_status_bloc/typing_status_bloc.dart'; // Импорт TypingStatusBloc
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:flutter/foundation.dart'; // Для kDebugMode

class ChatScreen extends StatefulWidget {
  final String chatId;
  // TODO: Возможно, передавать сюда имя чата для AppBar
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MessageBloc _messageBloc;
  late final TypingStatusBloc _typingStatusBloc; // Объявляем TypingStatusBloc
  final TextEditingController _messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  String? _currentUsername; // Для отображения в AppBar или для getTypingDisplayMessage

  Timer? _typingTimer;
  bool _isCurrentlyTyping = false; // Флаг, что мы уже отправили событие начала печати

  @override
  void initState() {
    super.initState();
    _messageBloc = MessageBloc(
      chatId: widget.chatId,
      getChatMessagesUseCase: sl<GetChatMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      observeMessagesUseCase: sl<ObserveMessagesUseCase>(),
      getPresignedUploadUrlUseCase: sl<GetPresignedUploadUrlUseCase>(),
      uploadFileToS3UseCase: sl<UploadFileToS3UseCase>(),
      sendMessageWithAttachmentUseCase: sl<SendMessageWithAttachmentUseCase>(),
    );
    _typingStatusBloc = sl<TypingStatusBloc>(); // Используем GetIt

    _messageBloc.add(LoadMessages(widget.chatId));

    // Получаем ID текущего пользователя для определения "своих" сообщений
    final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
      _currentUsername = authState.user.username; 
    }

    _scrollController.addListener(_onScroll);
    _messageTextController.addListener(_onTextChanged); // Слушатель для текстового поля
  }

  void _onTextChanged() {
    if (_currentUserId == null) return;

    if (_messageTextController.text.isNotEmpty) {
      if (!_isCurrentlyTyping) {
        _typingStatusBloc.add(LocalUserStartedTyping(widget.chatId));
        _isCurrentlyTyping = true; // Устанавливаем флаг
      }
      _typingTimer?.cancel(); // Отменяем предыдущий таймер
      _typingTimer = Timer(const Duration(seconds: 2), () { // 2 секунды неактивности
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chatId));
        _isCurrentlyTyping = false; // Сбрасываем флаг
      });
    } else {
      if (_isCurrentlyTyping) { // Если текст стал пустым и мы ранее отправляли "is typing"
        _typingTimer?.cancel();
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chatId));
        _isCurrentlyTyping = false;
      }
    }
  }

  @override
  void dispose() {
    _messageTextController.removeListener(_onTextChanged);
    _messageTextController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _typingTimer?.cancel(); // Отменяем таймер при dispose
    _messageBloc.close(); // Закрываем Bloc, так как он создается здесь
    _typingStatusBloc.close(); // Закрываем TypingStatusBloc
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = _messageBloc.state;
      if (state is MessageLoaded && !state.hasReachedMax) {
        // Загружаем следующую страницу, увеличивая pageNumber
        // Нужно хранить текущий pageNumber в состоянии блока или здесь
        // Пока упрощенно - загружаем "еще"
        // Чтобы корректно работала пагинация при прокрутке вверх,
        // нужно будет передавать текущее количество загруженных сообщений
        // и вычислять следующий pageNumber.
        // Для простоты сейчас, допустим, LoadMessages всегда загружает первую или следующую порцию.
        // Чтобы сделать "бесконечную" прокрутку вверх (загрузка старых сообщений),
        // нужно немного усложнить логику в _onLoadMessages и здесь.
        // Пока просто будем вызывать LoadMessages с pageNumber > 1 при достижении верха.
        // Если ListView.reverse = true, то "низ" это фактически начало списка (старые сообщения).
        // Если ListView.reverse = false, то "низ" это конец списка (новые сообщения).
        // Так как у нас reverse: true, _isBottom будет true, когда мы наверху списка (самые старые сообщения).
        // Это значит, что нужно загружать *предыдущую* страницу сообщений.
        // TODO: Реализовать корректную пагинацию при прокрутке вверх.
        // Сейчас LoadMessages с pageNumber > 1 добавляет в конец списка, а нам нужно в начало.
        // В MessageBloc _onLoadMessages уже умеет добавлять к текущим сообщениям.
        // Нужно передавать корректный page number.

        // int currentPage = (state.messages.length / _defaultPageSize).ceil() + 1;
        // _messageBloc.add(LoadMessages(widget.chatId, pageNumber: currentPage));
        // print("Attempting to load more messages, current count: ${state.messages.length}");
      }
    }
  }

  // bool get _isBottom { // Для reverse = false
  //   if (!_scrollController.hasClients) return false;
  //   final maxScroll = _scrollController.position.maxScrollExtent;
  //   final currentScroll = _scrollController.offset;
  //   return currentScroll >= (maxScroll * 0.9);
  // }

  bool get _isBottom { // Для reverse = true, "низ" означает верх списка
    if (!_scrollController.hasClients) return false;
    // Когда reverse = true, maxScrollExtent это "верх" списка (самые старые сообщения).
    // Мы хотим загружать больше, когда доскроллили до самого "верха".
    // offset будет близок к position.maxScrollExtent когда мы в самом верху.
    final currentScroll = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    // print("Scroll: $currentScroll, MaxScroll: $maxScroll");
    return currentScroll >= (maxScroll * 0.9) && maxScroll > 0; // Добавил maxScroll > 0 чтобы не триггерить на пустом списке
  }


  void _sendMessage() {
    final text = _messageTextController.text.trim();
    if (kDebugMode) {
      print('[ChatScreen] _sendMessage called. Text: "$text", Current User ID: $_currentUserId');
    }
    if (text.isNotEmpty && _currentUserId != null) {
      if (kDebugMode) {
        print('[ChatScreen] Dispatching SendNewMessage to MessageBloc.');
      }
      _messageBloc.add(
        SendNewMessage(
          CreateMessageModel(
            chatId: widget.chatId,
            text: text,
          ),
        ),
      );
      _messageTextController.clear();
      // После отправки текстового сообщения, если мы печатали, нужно остановить таймер и отправить stoppedTyping
      if (_isCurrentlyTyping) {
        _typingTimer?.cancel();
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chatId));
        _isCurrentlyTyping = false;
      }
    } else {
      if (kDebugMode) {
        print('[ChatScreen] SendNewMessage not dispatched. Text empty: ${text.isEmpty}, User ID null: ${_currentUserId == null}');
      }
    }
  }

  // Новый метод для выбора и отправки файла
  Future<void> _pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Можно уточнить типы, например FileType.image
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final xFile = XFile(platformFile.path!); 

        AttachmentType attachmentType = AttachmentType.otherFile; // Default
        final extension = platformFile.extension?.toLowerCase();
        
        if (kDebugMode) {
            print('[ChatScreen] Picked file: ${platformFile.name}, extension: $extension, size: ${platformFile.size}');
        }

        if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
          attachmentType = AttachmentType.image;
        } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
          attachmentType = AttachmentType.video;
        } else if (['mp3', 'wav', 'aac'].contains(extension)) {
          attachmentType = AttachmentType.audio;
        } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
          attachmentType = AttachmentType.document;
        }
        // Можно добавить больше проверок по MIME типу, если platformFile.mimeType доступен и надежен

        _messageBloc.add(SendAttachmentEvent(
          file: xFile,
          chatId: widget.chatId,
          attachmentType: attachmentType,
        ));
      } else {
        if (kDebugMode) {
          print('[ChatScreen] File picking cancelled or path is null.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ChatScreen] Error picking file: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выбора файла: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Чат'; // Дефолтный заголовок
    // Попробуем получить имя чата из ChatListBloc или другого источника, если доступно
    // Это просто пример, как можно было бы это сделать, если ChatModel доступен здесь
    // final chatListState = context.watch<ChatListBloc>().state;
    // if (chatListState is ChatListLoaded) {
    //   final currentChat = chatListState.chats.firstWhereOrNull((chat) => chat.id == widget.chatId);
    //   if (currentChat != null) {
    //      appBarTitle = currentChat.displayName(BlocProvider.of<AuthBloc>(context).state.user?.id ?? '');
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TypingStatusBloc, TypingStatusState>(
          bloc: _typingStatusBloc, // Явно указываем bloc
          builder: (context, typingState) {
            if (typingState is TypingStatusUpdated) {
              final displayMessage = typingState.getTypingDisplayMessage(widget.chatId, _currentUsername ?? 'Пользователь');
              if (displayMessage.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appBarTitle, style: const TextStyle(fontSize: 18)), 
                    Text(displayMessage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                  ],
                );
              }
            }
            return Text(appBarTitle);
          },
        ),
        actions: [
          BlocBuilder<MessageBloc, MessageState>(
            bloc: _messageBloc, // Явно указываем bloc, если он не через Provider.of получается
            builder: (context, state) {
              if (state is MessageSendingAttachment) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return const SizedBox.shrink(); // Ничего не показываем, если не загрузка
            },
          )
        ],
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _messageBloc),
          BlocProvider.value(value: _typingStatusBloc),
        ],
        child: BlocConsumer<MessageBloc, MessageState>(
          listener: (context, state) {
            if (state is MessageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: ${state.message}')),
              );
            }
            // Если сообщение отправлено успешно, оно придет через SignalR
            // и добавится в InternalMessageReceived.
            // Если нужно подтверждение отправки до получения по SignalR,
            // то SendMessageUseCase должен возвращать MessageModel,
            // а MessageBloc должен иметь состояние вроде MessageSendingSuccess
            // и добавлять сообщение в список временно.
            // Текущая реализация полагается на SignalR для обновления UI.
          },
          builder: (context, state) {
            Widget? bodyContent;
            if (state is MessageInitial || (state is MessageLoading && state is! MessageLoaded && state is! MessageSendingAttachment)) {
              bodyContent = const Center(child: CircularProgressIndicator());
            } else if (state is MessageLoaded || state is MessageSendingAttachment) {
              List<MessageModel> messagesToShow = [];
              bool hasReachedMaxPagination = false;

              if (state is MessageLoaded) {
                messagesToShow = state.messages;
                hasReachedMaxPagination = state.hasReachedMax;
              } else if (state is MessageSendingAttachment) {
                messagesToShow = state.messages;
                hasReachedMaxPagination = state.hasReachedMax; 
              }
              
              bodyContent = Column(
                children: [
                  Expanded(
                    child: messagesToShow.isEmpty
                        ? const Center(child: Text('Сообщений пока нет.')) 
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: messagesToShow.length,
                            reverse: true, 
                            padding: const EdgeInsets.all(8.0),
                            itemBuilder: (context, index) {
                              final message = messagesToShow[index];
                              final isMyMessage = message.senderId == _currentUserId;
                              return _buildMessageItem(message, isMyMessage, context);
                            },
                          ),
                  ),
                  _buildMessageInput(),
                ],
              );
            }
             else if (state is MessageError) {
                bodyContent = Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text('Ошибка загрузки: ${state.message}'),
                    ElevatedButton(
                        onPressed: () => _messageBloc.add(LoadMessages(widget.chatId)),
                        child: const Text('Повторить'),
                    )
                    ],
                ),
                );
            }
            return bodyContent ?? const Center(child: Text('Неизвестное состояние.'));
          },
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isMyMessage, BuildContext context) {
    return Align(
      key: ValueKey(message.id),
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMyMessage ? Theme.of(context).primaryColorLight : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.sender?.username != null && !isMyMessage) // Показываем имя отправителя для чужих сообщений
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.sender!.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isMyMessage ? Colors.white70 : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            if (message.text != null && message.text!.isNotEmpty)
              Text(message.text!),
            
            // Отображение вложений
            if (message.attachments != null && message.attachments!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: message.attachments!.map((att) {
                    // TODO: Сделать более красивое отображение вложений
                    // Иконка + имя файла, превью для картинок и т.д.
                    IconData iconData = Icons.insert_drive_file;
                    switch (att.type) {
                      case AttachmentType.image:
                        iconData = Icons.image;
                        break;
                      case AttachmentType.video:
                        iconData = Icons.videocam;
                        break;
                      case AttachmentType.audio:
                        iconData = Icons.audiotrack;
                        break;
                      case AttachmentType.document:
                        iconData = Icons.article;
                        break;
                      default:
                        iconData = Icons.insert_drive_file;
                    }
                    return InkWell(
                      onTap: () {
                        // TODO: Реализовать скачивание/открытие файла
                        if (kDebugMode) {
                          print('Tapped on attachment: ${att.fileName}, key: ${att.fileKey}, url: ${att.presignedUrl}');
                        }
                        // Нужно будет запросить presignedDownloadUrl и открыть его
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, size: 18, color: isMyMessage ? Colors.black87 : Colors.black54),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              att.fileName,
                              style: TextStyle(decoration: TextDecoration.underline, color: isMyMessage ? Colors.black : Colors.blue.shade800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                // TODO: Форматировать время TimeOfDay.fromDateTime(message.timestamp.toLocal()).format(context)
                message.timestamp.toLocal().toString().substring(11, 16), // Простое отображение времени HH:MM
                style: TextStyle(
                  fontSize: 10,
                  color: isMyMessage ? Colors.white70 : Colors.grey[600],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 1,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.attach_file), // Кнопка для прикрепления файла
            onPressed: _pickAndSendFile, // Вызываем наш новый метод
          ),
          Expanded(
            child: TextField(
              controller: _messageTextController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Введите сообщение...',
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
} 