import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart'; // Для ChatTypeModel
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart'; // Для доступа к текущему пользователю
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart'; // Для доступа к текущему пользователю
// Импорт для UserStatusBloc и его состояния
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart'; // ИМПОРТИРУЕМ ТОЛЬКО ЭТОТ ФАЙЛ
// import 'package:sigmail_client/presentation/blocs/user_status/user_status_state.dart'; // ЭТОТ ИМПОРТ НЕНУЖЕН
// import 'package:go_router/go_router.dart'; // Для навигации к экрану чата
// import 'package:sigmail_client/presentation/screens/chat/chat_screen.dart'; // Для навигации

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListBloc _chatListBloc;
  // Для диалога создания чата
  final _chatNameController = TextEditingController();
  final _participantIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatListBloc = sl<ChatListBloc>();
    _chatListBloc.add(const LoadChatList()); // Загружаем чаты при инициализации экрана
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        // TODO: Добавить кнопку для создания нового чата
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () {
        //       // TODO: Показать диалог/экран для создания нового чата
        //       // Пример: Показать диалог для ввода ID пользователя/ей для нового чата
        //       // _showCreateChatDialog(context);
        //     },
        //   ),
        // ],
      ),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        bloc: _chatListBloc,
        listener: (context, state) {
          if (state is ChatListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
          if (state is ChatListCreated) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Чат успешно создан!')),
            );
            // ChatListBloc должен сам обновить список чатов и перейти в ChatListLoaded
            // или мы можем принудительно добавить LoadChatList, если это не происходит автоматически
            // _chatListBloc.add(LoadChatList()); // Это может быть избыточно, если ChatListBloc правильно обновляет состояние
          }
        },
        builder: (context, state) {
          if (state is ChatListLoading || state is ChatListInitial || state is ChatListCreating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            if (state.chats.isEmpty) {
              return const Center(child: Text('У вас пока нет чатов.'));
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                // print('[ChatListScreen] Chat data: ${chat.toString()}'); // Оставим пока закомментированным

                String displayName = chat.name ?? '';
                String? otherParticipantId;

                // Отладочный print для chat.name и chat.type
                print('[ChatListScreen] Processing chat ID: ${chat.id}, Name: "${chat.name}", Type: ${chat.type}');

                if (chat.type == ChatTypeModel.private && (chat.name == null || chat.name!.isEmpty)) {
                  print('[ChatListScreen] Chat ${chat.id} is Private and has no name. Attempting to find other member.');
                  final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
                  String? currentUserId;
                  if (authState is Authenticated) {
                    currentUserId = authState.user.id;
                    print('[ChatListScreen] CurrentUserID: $currentUserId');
                  } else {
                    print('[ChatListScreen] AuthState is not Authenticated.');
                  }

                  if (chat.members != null && chat.members!.isNotEmpty) {
                    print('[ChatListScreen] Chat ${chat.id} has ${chat.members!.length} members.');
                    chat.members!.forEach((member) {
                      print('[ChatListScreen] Member: ID=${member.id}, Username="${member.username}"');
                    });

                    final otherMember = chat.members!.firstWhere(
                      (member) => member.id != currentUserId,
                      orElse: () {
                        print('[ChatListScreen] Could not find other member for chat ${chat.id} where member.id != $currentUserId. Falling back to first member.');
                        // Добавим проверку, что chat.members не пустой перед доступом к first, хотя это уже проверяется chat.members!.isNotEmpty
                        return chat.members!.first; 
                      },
                    );
                    print('[ChatListScreen] For chat ${chat.id}, otherMember found: ID=${otherMember.id}, Username="${otherMember.username}"');
                    // Проверка на null или пустой username другого участника
                    if (otherMember.username != null && otherMember.username!.isNotEmpty) {
                        displayName = 'Чат с ${otherMember.username}';
                    } else {
                        print('[ChatListScreen] otherMember.username is null or empty for ID ${otherMember.id}. Using default name for private chat.');
                        displayName = 'Приватный чат (ошибка имени)'; // Изменено для ясности в логах
                    }
                    otherParticipantId = otherMember.id;
                  } else {
                    print('[ChatListScreen] For chat ${chat.id}, members list is null or empty. Using default name.');
                    displayName = 'Приватный чат';
                  }
                } else if (chat.type == ChatTypeModel.group) {
                    // Если это групповой чат, и имя пустое, можно тоже поставить заглушку
                    if (displayName.isEmpty) {
                        displayName = 'Групповой чат';
                    }
                }

                if (displayName.isEmpty) {
                  print('[ChatListScreen] displayName is empty for chat ${chat.id}. Setting to "Чат без имени". Original chat.name: "${chat.name}"');
                  displayName = 'Чат без имени';
                }

                final lastMessageText = chat.lastMessage?.text ?? 'Нет сообщений';
                final lastMessageTime = chat.lastMessage?.timestamp?.toLocal().toString().substring(0, 16) ?? ''; 

                // Финальный отладочный print перед ListTile
                print('[ChatListScreen] FINAL for chat ${chat.id}: displayName="$displayName", otherParticipantId="$otherParticipantId"');

                return BlocBuilder<UserStatusBloc, UserStatusState>(
                  // Если UserStatusBloc предоставляется глобально, его можно получить так:
                  // bloc: BlocProvider.of<UserStatusBloc>(context),
                  // или если он зарегистрирован в sl и вы хотите создать экземпляр для этого экрана (менее предпочтительно для глобального состояния)
                  // bloc: sl<UserStatusBloc>(), 
                  // Для доступа к уже существующему экземпляру, зарегистрированному в sl и предоставленному выше по дереву:
                  bloc: context.read<UserStatusBloc>(), // Убедитесь, что UserStatusBloc предоставлен через Provider выше
                  builder: (context, userStatusState) {
                    bool isOnline = false;
                    if (otherParticipantId != null && userStatusState.userStatuses.containsKey(otherParticipantId)) {
                      isOnline = userStatusState.userStatuses[otherParticipantId]!.isOnline;
                    }

                    return ListTile(
                      leading: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Ч'),
                          ),
                          if (chat.type == ChatTypeModel.private && otherParticipantId != null)
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      title: Text(displayName),
                      subtitle: Text(lastMessageText),
                      trailing: Text(lastMessageTime), 
                      onTap: () {
                        context.goNamed(
                          AppRoutes.chatMessagesNamed, 
                          pathParameters: {'chatId': chat.id},
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            // Fallback for other states, though ideally covered by ChatListError
            return const Center(child: Text('Неизвестное состояние списка чатов.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateChatDialog(context);
        },
        tooltip: 'Создать чат',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateChatDialog(BuildContext context) async {
    // Получаем ID текущего пользователя, чтобы не добавлять его самого к себе в участники по ошибке
    // или чтобы использовать его, если API ожидает всех участников, включая создателя.
    // Убедимся, что наш CreateChatDto на бэке не добавляет создателя автоматически.
    // Судя по CreateChatDto (Name, ParticipantIds), создатель неявно определяется по токену,
    // а ParticipantIds - это ДРУГИЕ участники.
    String? currentUserId;
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Пользователь должен нажать кнопку
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Создать новый чат'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _chatNameController,
                  decoration: const InputDecoration(hintText: "Название чата (опционально для диалога)"),
                ),
                TextField(
                  controller: _participantIdController,
                  decoration: const InputDecoration(hintText: "ID участника"),
                ),
                if (currentUserId != null) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Ваш ID: $currentUserId (для справки)', style: Theme.of(context).textTheme.bodySmall),
                  )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _chatNameController.clear();
                _participantIdController.clear();
              },
            ),
            TextButton(
              child: const Text('Создать'),
              onPressed: () {
                final chatName = _chatNameController.text;
                final participantId = _participantIdController.text;

                if (participantId.isNotEmpty) {
                  // Проверяем, что ID участника не совпадает с ID текущего пользователя,
                  // если это не разрешено логикой (обычно для диалогов нет смысла).
                  if (currentUserId != null && participantId == currentUserId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Нельзя создать чат с самим собой таким образом.')),
                    );
                    return;
                  }

                  // Определяем тип чата. Пока только Private.
                  // Если chatName не пустой, можно было бы считать Group, но серверная DTO
                  // позволяет Name для Private чатов тоже (например, если пользователь его переименует).
                  // Сервер, скорее всего, сам определит имя для Private чата, если name is null.
                  final chatType = ChatTypeModel.private; // Исправлено на строчную 'private'

                  final model = CreateChatModel(
                    name: chatName.isNotEmpty ? chatName : null,
                    type: chatType, // Добавляем тип
                    memberIds: [participantId], // Переименовано в memberIds
                    // description: null, // Пока не используем
                  );
                  _chatListBloc.add(CreateNewChat(model));

                  Navigator.of(dialogContext).pop();
                  _chatNameController.clear();
                  _participantIdController.clear();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID участника не может быть пустым.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _chatNameController.dispose();
    _participantIdController.dispose();
    // Не закрываем _chatListBloc здесь, если он получается через sl<ChatListBloc>()
    // и его жизненный цикл управляется GetIt или другим BlocProvider-ом выше по дереву.
    // Если ChatListBloc создается здесь локально, то _chatListBloc.close();
    super.dispose();
  }
} 