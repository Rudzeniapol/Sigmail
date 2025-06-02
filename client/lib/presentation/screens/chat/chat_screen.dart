import 'dart:async'; // Для Timer
import 'dart:io'; // Для File

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart'; // <--- ДОБАВЛЕН ИМПОРТ CHATMODEL
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart'; // <--- ДОБАВЛЕН ИМПОРТ UserSimpleModel
import 'package:sigmail_client/data/models/reaction/reaction_model.dart'; // ДОБАВЛЕНО ЕСЛИ НЕТ
import 'package:sigmail_client/domain/use_cases/chat/get_chat_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/send_message_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/get_presigned_upload_url_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/upload_file_to_s3_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/send_message_with_attachment_use_case.dart';
import 'package:sigmail_client/domain/use_cases/message/add_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/message/remove_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/mark_messages_as_read_use_case.dart'; // <--- добавлено
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

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
// TODO: Импортировать экран списка участников, когда он будет создан
// import 'chat_participants_screen.dart'; 
import 'package:sigmail_client/presentation/screens/chat/chat_participants_screen.dart'; // <--- ДОБАВЛЕН ИМПОРТ
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker; // ИЗМЕНЕНО: добавлен префикс
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ChatScreen extends StatefulWidget {
  // final String chatId; // Заменяем на chatModel
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

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
      chatId: widget.chat.id, // Используем ID из chatModel
      getChatMessagesUseCase: sl<GetChatMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      observeMessagesUseCase: sl<ObserveMessagesUseCase>(),
      getPresignedUploadUrlUseCase: sl<GetPresignedUploadUrlUseCase>(),
      uploadFileToS3UseCase: sl<UploadFileToS3UseCase>(),
      sendMessageWithAttachmentUseCase: sl<SendMessageWithAttachmentUseCase>(),
      addReactionUseCase: sl<AddReactionUseCase>(),
      removeReactionUseCase: sl<RemoveReactionUseCase>(),
      markMessagesAsReadUseCase: sl<MarkMessagesAsReadUseCase>(), // <--- добавлено
      chatRepository: sl<ChatRepository>(),
    );
    _typingStatusBloc = sl<TypingStatusBloc>(); // Используем GetIt

    _messageBloc.add(LoadMessages(widget.chat.id)); // Используем ID из chatModel

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
        _typingStatusBloc.add(LocalUserStartedTyping(widget.chat.id)); // Используем ID из chatModel
        _isCurrentlyTyping = true; // Устанавливаем флаг
      }
      _typingTimer?.cancel(); // Отменяем предыдущий таймер
      _typingTimer = Timer(const Duration(seconds: 2), () { // 2 секунды неактивности
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chat.id)); // Используем ID из chatModel
        _isCurrentlyTyping = false; // Сбрасываем флаг
      });
    } else {
      if (_isCurrentlyTyping) { // Если текст стал пустым и мы ранее отправляли "is typing"
        _typingTimer?.cancel();
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chat.id)); // Используем ID из chatModel
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
        // _messageBloc.add(LoadMessages(widget.chat.id, pageNumber: currentPage));
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
            chatId: widget.chat.id, // Используем ID из chatModel
            text: text,
          ),
        ),
      );
      _messageTextController.clear();
      // После отправки текстового сообщения, если мы печатали, нужно остановить таймер и отправить stoppedTyping
      if (_isCurrentlyTyping) {
        _typingTimer?.cancel();
        _typingStatusBloc.add(LocalUserStoppedTyping(widget.chat.id)); // Используем ID из chatModel
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
          chatId: widget.chat.id, // Используем ID из chatModel
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

  void _showEmojiPicker(BuildContext context, MessageModel message) {
    final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
    String? currentUserId;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return emoji_picker.EmojiPicker(
            onEmojiSelected: (emoji_picker.Category? category, emoji_picker.Emoji emoji) {
              Navigator.pop(context); // Закрываем BottomSheet
              if (currentUserId == null) return;

              final existingReaction = message.reactions.firstWhere(
                (r) => r.emoji == emoji.emoji && r.userIds.contains(currentUserId),
                // Возвращаем null, если не найдено, чтобы не создавать пустую ReactionModel
                // orElse: () => const ReactionModel(emoji: '', userIds: []), 
                orElse: () => ReactionModel.empty(), // Используем статический конструктор для "пустой" реакции
              );

              if (existingReaction.emoji.isNotEmpty) {
                _messageBloc.add(RemoveReactionRequested(
                  messageId: message.id,
                  emoji: emoji.emoji,
                ));
              } else {
                _messageBloc.add(AddReactionRequested(
                  messageId: message.id,
                  emoji: emoji.emoji,
                ));
              }
            },
            config: emoji_picker.Config(
              height: 256,
              checkPlatformCompatibility: true,
              emojiViewConfig: emoji_picker.EmojiViewConfig(
                // emojiSizeMax: 28 * (defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0), // Пример для iOS
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              // swapCategoryAndBottomBar: false, // Параметра нет
              skinToneConfig: const emoji_picker.SkinToneConfig(),
              categoryViewConfig: emoji_picker.CategoryViewConfig(
                backgroundColor: Theme.of(context).cardColor,
                indicatorColor: Theme.of(context).primaryColor,
                iconColorSelected: Theme.of(context).primaryColor,
              ),
              bottomActionBarConfig: const emoji_picker.BottomActionBarConfig(
                enabled: false, // Убираем нижнюю панель, если не нужна
              ),
              searchViewConfig: const emoji_picker.SearchViewConfig(), // Можно настроить или оставить по умолчанию
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Определяем заголовок AppBar на основе типа чата и его имени
    String appBarTitle;
    if (widget.chat.type == ChatTypeModel.private) {
      // Для приватных чатов, если есть имя (например, у контакта), используем его.
      // Или можно получить имя другого участника из widget.chat.members, если оно там есть.
      // Сейчас просто:
      final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
      String currentUsernameDisplay = "";
       if (authState is Authenticated) {
        currentUsernameDisplay = authState.user.username ?? "Я";
      }
      
      final otherMember = widget.chat.members?.firstWhere(
        (member) => member.id != (authState is Authenticated ? authState.user.id : ""),
        orElse: () => widget.chat.members?.isNotEmpty == true ? widget.chat.members!.first : UserSimpleModel(id: '', username: 'Неизвестно') // Заглушка
      );
      appBarTitle = otherMember?.username ?? 'Приватный чат';

    } else if (widget.chat.name != null && widget.chat.name!.isNotEmpty) {
      appBarTitle = widget.chat.name!;
    } else {
      appBarTitle = 'Групповой чат'; // Дефолт для группы без имени
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (widget.chat.type == ChatTypeModel.group) // Показываем кнопку только для групповых чатов
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                // Навигация на экран участников чата
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatParticipantsScreen(chat: widget.chat),
                  ),
                );
              },
            ),
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
                        ? const Center(child: Text('No messages yet.')) 
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
                    Text('Failed to load: ${state.message}'),
                    ElevatedButton(
                        onPressed: () => _messageBloc.add(LoadMessages(widget.chat.id)),
                        child: const Text('Retry'),
                    )
                    ],
                ),
                );
            }
            return bodyContent ?? const Center(child: Text('Unknown state.'));
          },
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isMyMessage, BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state is Authenticated 
        ? (context.read<AuthBloc>().state as Authenticated).user.id 
        : null;

    return GestureDetector(
      onLongPress: () {
        _showEmojiPicker(context, message);
      },
      child: Align(
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
              if (message.sender?.username != null && !isMyMessage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    message.sender!.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(
                    color: isMyMessage ? Colors.black : Colors.black87,
                  ),
                ),
              
              // Отображение вложений
              if (message.attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: message.attachments.map((att) {
                      if (kDebugMode) {
                        print('[Attachment] Full attachment object: ' + att.toString());
                      }
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
                        onTap: () async {
                          final url = att.presignedUrl;
                          if (kDebugMode) {
                            print('[Attachment] Tap: presignedUrl=${url ?? 'null'} (fileName: ${att.fileName})');
                          }
                          if (url != null && url.isNotEmpty) {
                            try {
                              final response = await http.get(Uri.parse(url));
                              if (response.statusCode == 200) {
                                final bytes = response.bodyBytes;
                                final dir = await getTemporaryDirectory();
                                final filePath = '${dir.path}/${att.fileName}';
                                final file = File(filePath);
                                await file.writeAsBytes(bytes);
                                await OpenFile.open(filePath);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка скачивания файла: ${response.statusCode}')),
                                );
                              }
                            } catch (e) {
                              if (kDebugMode) print('[Attachment] Ошибка скачивания/открытия: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка открытия файла: ${e.toString()}')),
                              );
                            }
                          } else {
                            if (kDebugMode) print('[Attachment] presignedUrl is null or empty (fileName: ${att.fileName})');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No download link available.')),
                            );
                          }
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
              ),
              // Отображение реакций
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Wrap(
                    spacing: 6.0, // Горизонтальный отступ между реакциями
                    runSpacing: 4.0, // Вертикальный отступ, если реакции переносятся на новую строку
                    alignment: isMyMessage ? WrapAlignment.end : WrapAlignment.start,
                    children: message.reactions.map((reaction) {
                      // Пропускаем реакции без пользователей (на всякий случай)
                      if (reaction.userIds.isEmpty) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isMyMessage 
                              ? Colors.blue.shade700.withOpacity(0.8) 
                              : Colors.grey.shade400.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isMyMessage ? Colors.blue.shade300 : Colors.grey.shade500,
                            width: 0.5,
                          )
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Чтобы контейнер не растягивался
                          children: [
                            Text(reaction.emoji, style: const TextStyle(fontSize: 12)),
                            if (reaction.userIds.length > 1) // Показываем количество, только если оно больше 1
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  reaction.userIds.length.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMyMessage ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
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