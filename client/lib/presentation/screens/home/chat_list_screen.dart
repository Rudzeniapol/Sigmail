import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart'; // Для ChatTypeModel
import 'package:sigmail_client/data/models/user/user_simple_model.dart'; // <<--- ДОБАВЛЕН ИМПОРТ
import 'package:sigmail_client/data/models/attachment/attachment_model.dart'; // Для AttachmentModel
import 'package:sigmail_client/domain/enums/attachment_type.dart'; // Для enum AttachmentType
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_state.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart'; // Для доступа к текущему пользователю
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart'; // Для доступа к текущему пользователю
// Импорт для UserStatusBloc и его состояния
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart'; // ИМПОРТИРУЕМ ТОЛЬКО ЭТОТ ФАЙЛ
import 'package:collection/collection.dart'; // <<--- ДОБАВЛЕН ИМПОРТ
// import 'package:sigmail_client/presentation/blocs/user_status/user_status_state.dart'; // ЭТОТ ИМПОРТ НЕНУЖЕН
// import 'package:go_router/go_router.dart'; // Для навигации к экрану чата
// import 'package:sigmail_client/presentation/screens/chat/chat_screen.dart'; // Для навигации
import 'package:sigmail_client/presentation/blocs/user_search/user_search_bloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListBloc _chatListBloc;
  final _chatNameController = TextEditingController(); // Для имени группового чата
  // Контроллер для поля поиска убираем из состояния экрана, 
  // он будет создаваться внутри диалога, чтобы быть связанным с UserSearchBloc
  // final _userSearchController = TextEditingController(); 

  // Эти переменные тоже больше не нужны на уровне состояния экрана
  // List<UserSimpleModel> _searchResults = [];
  // bool _isSearching = false;
  // UserSimpleModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _chatListBloc = sl<ChatListBloc>();
    _chatListBloc.add(const LoadChatList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateChatDialog(context);
            },
          ),
        ],
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

                // Отладочный вывод для chat.name, особенно для приватных чатов
                if (chat.type == ChatTypeModel.private) {
                  print('[ChatListScreen] Processing private chat ${chat.id}, initial chat.name from model: "${chat.name}"');
                }

                String displayName;
                String? otherParticipantId;
                String? currentUserId;

                  final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;
                  if (authState is Authenticated) {
                    currentUserId = authState.user.id;
                  } else {
                  print('[ChatListScreen] Warning: Could not get currentUserId, authState is not Authenticated.');
                  }

                if (chat.type == ChatTypeModel.private) {
                  if (currentUserId != null && currentUserId.isNotEmpty) {
                  if (chat.members != null && chat.members!.isNotEmpty) {
                      // Используем firstWhereOrNull из пакета collection
                      UserSimpleModel? potentialOtherMember = chat.members!.firstWhereOrNull(
                        (member) => member.id != currentUserId
                      );

                      UserSimpleModel? otherMember;

                      if (potentialOtherMember != null) {
                        otherMember = potentialOtherMember;
                      } else {
                        // Другой участник не найден. Проверяем, не чат ли это с самим собой.
                        if (chat.members!.length == 1 && chat.members!.first.id == currentUserId) {
                          otherMember = chat.members!.first; // Это текущий пользователь
                           print('[ChatListScreen] Private chat ${chat.id}: Determined as chat with self (single member is current user).');
                        } else {
                           print('[ChatListScreen] Private chat ${chat.id}: No other member found directly, and not a simple chat with self. Members: ${chat.members!.map((m) => 'id:${m.id},name:${m.username}').join('; ')}');
                           // В этом случае otherMember останется null
                        }
                      }
                      
                      if (otherMember != null) {
                        if (otherMember.id == currentUserId) { // Случай "заметок себе" или единственного участника
                           displayName = otherMember.username != null && otherMember.username!.isNotEmpty
                                         ? 'Заметки (${otherMember.username})'
                                         : 'Мой чат';
                           print('[ChatListScreen] Private chat ${chat.id} is with self: "${displayName}"');
                        } else if (otherMember.username != null && otherMember.username!.isNotEmpty) {
                        displayName = 'Чат с ${otherMember.username}';
                           print('[ChatListScreen] Private chat ${chat.id} with ${otherMember.username}: "${displayName}"');
                        } else {
                          displayName = 'Приватный чат';
                          print('[ChatListScreen] Private chat ${chat.id}: Other member ${otherMember.id} found, but username is null or empty. Fallback to "$displayName".');
                        }
                        otherParticipantId = otherMember.id;
                      } else {
                        // otherMember остался null (не найден другой участник и это не чат с самим собой)
                        displayName = 'Приватный чат';
                        print('[ChatListScreen] Private chat ${chat.id}: otherMember is null (no other participant and not self-chat). Fallback to "$displayName". Members count: ${chat.members?.length}.');
                      }
                    } else {
                      displayName = 'Приватный чат';
                      print('[ChatListScreen] Private chat ${chat.id}: members list is null or empty. Fallback to "$displayName".');
                    }
                  } else {
                    displayName = 'Приватный чат';
                    print('[ChatListScreen] Private chat ${chat.id}: currentUserId is null or empty. Fallback to "$displayName".');
                  }
                } else { // Group, Channel, etc.
                  if (chat.name != null && chat.name!.isNotEmpty) {
                    displayName = chat.name!;
                  } else {
                    if (chat.type == ChatTypeModel.group) {
                        displayName = 'Групповой чат';
                    } else if (chat.type == ChatTypeModel.channel) {
                      displayName = 'Канал';
                    } else {
                      displayName = 'Чат'; // Общий для других типов без имени
                    }
                    print('[ChatListScreen] Non-private chat ${chat.id} (type ${chat.type}) has no name. Fallback to "$displayName".');
                  }
                }
                
                // Финальная проверка, если вдруг displayName остался неинициализированным (маловероятно с новой логикой)
                // Но для безопасности, если предыдущие условия не сработали
                if (displayName == null || displayName.isEmpty) {
                    print('[ChatListScreen] Chat ${chat.id} displayName ended up null or empty. Fallback to "Чат (ошибка)". Original name: "${chat.name}", type: ${chat.type}');
                    displayName = 'Чат (ошибка)';
                }

                String lastMessageText;
                if (chat.lastMessage?.text != null && chat.lastMessage!.text!.isNotEmpty) {
                  lastMessageText = chat.lastMessage!.text!;
                } else if (chat.lastMessage?.attachments != null && chat.lastMessage!.attachments.isNotEmpty) {
                  final attachment = chat.lastMessage!.attachments.first;
                  String attachmentDescription = attachment.fileName ?? "Вложение"; // Изначально просто имя файла или "Вложение"
                  
                  // Проверяем тип вложения и формируем более описательный текст
                  // Предполагается, что у вас есть AttachmentType в attachment.type
                  if (attachment.type != null) {
                      switch (attachment.type!) {
                          case AttachmentType.image:
                            attachmentDescription = "[Изображение]";
                            if (attachment.fileName != null && attachment.fileName!.isNotEmpty) {
                                attachmentDescription += " ${attachment.fileName}";
                            }
                            break;
                          case AttachmentType.video:
                            attachmentDescription = "[Видео]";
                             if (attachment.fileName != null && attachment.fileName!.isNotEmpty) {
                                attachmentDescription += " ${attachment.fileName}";
                            }
                            break;
                          case AttachmentType.audio:
                            attachmentDescription = "[Аудио]";
                             if (attachment.fileName != null && attachment.fileName!.isNotEmpty) {
                                attachmentDescription += " ${attachment.fileName}";
                            }
                            break;
                          case AttachmentType.document:
                            attachmentDescription = "[Документ]";
                             if (attachment.fileName != null && attachment.fileName!.isNotEmpty) {
                                attachmentDescription += " ${attachment.fileName}";
                            }
                            break;
                          case AttachmentType.otherFile:
                            attachmentDescription = "[Файл]"; // Для otherFile используем "[Файл]"
                             if (attachment.fileName != null && attachment.fileName!.isNotEmpty) {
                                attachmentDescription += " ${attachment.fileName}";
                            }
                            break;
                      }
                  }
                  lastMessageText = attachmentDescription.trim(); 
                } else {
                  lastMessageText = 'Нет сообщений';
                }

                final lastMessageTime = chat.lastMessage?.timestamp?.toLocal().toString().substring(0, 16) ?? ''; 

                // Финальный отладочный print перед ListTile
                print('[ChatListScreen] FINAL for chat ${chat.id}: displayName="$displayName", otherParticipantId="$otherParticipantId", type=${chat.type}, chat.name="${chat.name}", membersCount=${chat.members?.length}');

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
                            // TODO: Заменить на реальный аватар чата
                            // backgroundImage: chat.avatarUrl != null ? NetworkImage(chat.avatarUrl!) : null,
                            child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?'),
                          ),
                          if (chat.type == ChatTypeModel.private && isOnline)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                        ],
                      ),
                      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(lastMessageText, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(lastMessageTime, style: Theme.of(context).textTheme.bodySmall),
                          if (chat.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blue, // Или ваш Theme.colorScheme.primary
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        context.goNamed(
                          AppRoutes.chatMessagesNamed,
                          pathParameters: {'chatId': chat.id},
                          extra: chat, // <--- ПЕРЕДАЕМ ВЕСЬ CHATMODEL
                        );
                        // Сбрасываем счетчик непрочитанных сообщений для этого чата в UI (локально)
                        // BLoC должен обновить это состояние при следующем LoadChatList или через SignalR
                        if (chat.unreadCount > 0) {
                          _chatListBloc.add(MarkChatAsReadEvent(chat.id));
                        }
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

  void _showCreateChatDialog(BuildContext context) {
    // Локальный контроллер для поля поиска в диалоге
    final TextEditingController userSearchDialogController = TextEditingController();
    UserSimpleModel? selectedUserForDialog;
    ChatTypeModel _selectedChatType = ChatTypeModel.private;
    List<UserSimpleModel> selectedGroupMembers = [];
    _chatNameController.clear(); // <<< Очищаем контроллер имени группы перед открытием диалога

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Предоставляем UserSearchBloc для диалога
        return BlocProvider<UserSearchBloc>(
          create: (context) => sl<UserSearchBloc>(),
          // Оборачиваем весь AlertDialog в StatefulBuilder
          child: StatefulBuilder( 
            builder: (BuildContext context, StateSetter setStateAlertDialog) { // setStateAlertDialog для всего диалога
              // Получаем ID текущего пользователя
    String? currentUserId;
              final authState = BlocProvider.of<AuthBloc>(dialogContext, listen: false).state;
    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

              return BlocConsumer<UserSearchBloc, UserSearchState>(
                listener: (context, state) {
                  // Можно добавить обработку ошибок поиска, если нужно
                  if (state is UserSearchError) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Ошибка поиска: ${state.message}')),
                    );
                  }
                },
                builder: (context, searchState) {
                  // Получаем UserSearchBloc из контекста BlocProvider
                  final userSearchBloc = BlocProvider.of<UserSearchBloc>(context);

        return AlertDialog(
          title: const Text('Создать новый чат'),
                    // Убрали вложенный StatefulBuilder, так как теперь есть внешний
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                          // Переключатель типа чата
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ToggleButtons(
                              isSelected: [
                                _selectedChatType == ChatTypeModel.private,
                                _selectedChatType == ChatTypeModel.group,
                              ],
                              onPressed: (int index) {
                                setStateAlertDialog(() {
                                  if (index == 0) {
                                    _selectedChatType = ChatTypeModel.private;
                                    // При переключении на приватный, очищаем список групповых участников 
                                    // и выбранного пользователя, если он был выбран для группы
                                    selectedGroupMembers.clear();
                                    selectedUserForDialog = null; 
                                    userSearchDialogController.clear();
                                    BlocProvider.of<UserSearchBloc>(context).add(ClearSearch());
                                  } else {
                                    _selectedChatType = ChatTypeModel.group;
                                    // При переключении на группу, если был выбран юзер для приватного, очищаем его
                                    selectedUserForDialog = null;
                                    userSearchDialogController.clear();
                                    BlocProvider.of<UserSearchBloc>(context).add(ClearSearch());
                                  }
                                });
                              },
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Приватный'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Группа'),
                                ),
                              ],
                            ),
                          ),
                          // Поле для имени группы (показываем, только если выбран тип "Группа")
                          if (_selectedChatType == ChatTypeModel.group)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                  controller: _chatNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Название группы',
                                  hintText: 'Введите название группы',
                                ),
                              ),
                            ),
                          
                          // Отображение выбранных участников для группы
                          if (_selectedChatType == ChatTypeModel.group && selectedGroupMembers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Участники:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: selectedGroupMembers.map((user) {
                                      return Chip(
                                        label: Text(user.username),
                                        avatar: CircleAvatar( // Опционально: можно добавить аватар
                                          child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?'),
                                        ),
                                        onDeleted: () {
                                          setStateAlertDialog(() {
                                            selectedGroupMembers.removeWhere((member) => member.id == user.id);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),

                          // Поле поиска пользователя
                TextField(
                            controller: userSearchDialogController,
                            decoration: InputDecoration(
                              labelText: 'Поиск пользователя по имени или email',
                              hintText: 'Введите имя пользователя или email',
                              suffixIcon: userSearchDialogController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      userSearchDialogController.clear();
                                      userSearchBloc.add(ClearSearch());
                                      setStateAlertDialog(() { // Используем setStateAlertDialog
                                        selectedUserForDialog = null;
                                      });
                                    },
                                  )
                                : null,
                            ),
                            onChanged: (term) {
                              if (term.length > 2) { // Начинаем поиск после ввода 3 символов
                                userSearchBloc.add(SearchTermChanged(term));
                              } else if (term.isEmpty) { // Если поле очищено полностью
                                userSearchBloc.add(ClearSearch());
                              } else { 
                                // Если менее 3 символов, но не пусто, можем не очищать, 
                                // а просто не слать запрос, чтобы не показывать "не найдено" преждевременно
                                // Либо, если хотим очищать результаты при коротком запросе:
                                userSearchBloc.add(ClearSearch()); 
                              }
                              setStateAlertDialog(() { // Используем setStateAlertDialog
                               selectedUserForDialog = null; // Сбрасываем выбор при изменении текста
                              });
                            },
                          ),
                          if (searchState is UserSearchLoading)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (searchState is UserSearchLoaded)
                            if (searchState.users.isEmpty && userSearchDialogController.text.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Пользователи не найдены.'),
                              )
                            else if (searchState.users.isNotEmpty)
                              SizedBox(
                                height: 200.0, // Ограничиваем высоту списка
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: (_selectedChatType == ChatTypeModel.group && currentUserId != null)
                                      ? searchState.users.where((user) => user.id != currentUserId).length
                                      : searchState.users.length,
                                  itemBuilder: (context, index) {
                                    List<UserSimpleModel> displayableUsers = searchState.users;
                                    if (_selectedChatType == ChatTypeModel.group && currentUserId != null) {
                                      displayableUsers = searchState.users.where((user) => user.id != currentUserId).toList();
                                    }
                                    
                                    if (index >= displayableUsers.length) { // Защита от выхода за пределы, если itemCount был неточен
                                        return const SizedBox.shrink(); 
                                    }
                                    final user = displayableUsers[index];

                                    // Определяем, выбран ли пользователь, в зависимости от типа чата
                                    bool isUserSelectedForDialog;
                                    if (_selectedChatType == ChatTypeModel.private) {
                                      isUserSelectedForDialog = selectedUserForDialog?.id == user.id;
                                    } else { // ChatTypeModel.group
                                      isUserSelectedForDialog = selectedGroupMembers.any((member) => member.id == user.id);
                                    }

                                    return ListTile(
                                      title: Text(user.username),
                                      subtitle: Text(user.id), 
                                      tileColor: isUserSelectedForDialog ? Colors.blue.withOpacity(0.2) : null,
                                      onTap: () {
                                        final userSearchBlocForTap = BlocProvider.of<UserSearchBloc>(context);
                                        setStateAlertDialog(() {
                                          if (_selectedChatType == ChatTypeModel.private) {
                                            if (isUserSelectedForDialog) { // User is currently selected, and is being deselected
                                              selectedUserForDialog = null;
                                              userSearchDialogController.clear();
                                              userSearchBlocForTap.add(ClearSearch());
                                            } else { // User is not selected, and is being selected
                                              selectedUserForDialog = user;
                                              userSearchDialogController.text = user.username;
                                              // Keep search results visible for context. 
                                              // If user types more, onChanged in TextField will handle clearing/new search.
                                            }
                                          } else { // ChatTypeModel.group
                                            if (selectedGroupMembers.any((member) => member.id == user.id)) {
                                              // User is in selectedGroupMembers, remove them
                                              selectedGroupMembers.removeWhere((member) => member.id == user.id);
                                              // Optional: Do not clear search here, as user might have searched to find this user to remove.
                                            } else {
                                              // User is not in selectedGroupMembers, add them
                                              selectedGroupMembers.add(user);
                                              userSearchDialogController.clear(); // Clear text field to easily search for next user
                                              userSearchBlocForTap.add(ClearSearch()); // Clear search results
                                            }
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                          if (searchState is UserSearchError && userSearchDialogController.text.isNotEmpty)
                  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Ошибка: ${searchState.message}', style: const TextStyle(color: Colors.red)),
                            ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                           _chatNameController.clear(); // Очищаем контроллер имени при закрытии
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Создать'),
                        onPressed: (_selectedChatType == ChatTypeModel.private && selectedUserForDialog != null) ||
                                   (_selectedChatType == ChatTypeModel.group && selectedGroupMembers.isNotEmpty && _chatNameController.text.trim().isNotEmpty)
                          ? () {
                              if (_selectedChatType == ChatTypeModel.private && selectedUserForDialog != null) {
                                final createChatModel = CreateChatModel(
                                  name: null, 
                                  type: ChatTypeModel.private, 
                                  memberIds: [selectedUserForDialog!.id],
                                );
                                _chatListBloc.add(CreateNewChat(createChatModel));
                              } else if (_selectedChatType == ChatTypeModel.group && selectedGroupMembers.isNotEmpty && _chatNameController.text.trim().isNotEmpty) {
                                final createChatModel = CreateChatModel(
                                  name: _chatNameController.text.trim(),
                                  type: ChatTypeModel.group,
                                  memberIds: selectedGroupMembers.map((user) => user.id).toList(),
                                );
                                _chatListBloc.add(CreateNewChat(createChatModel));
                              }
                              _chatNameController.clear(); // Очищаем контроллер имени после создания
                  Navigator.of(dialogContext).pop();
                            }
                          : null, 
            ),
          ],
        );
      },
    );
            }
          ),
        );
      },
    ).then((_) {
      // Очищаем контроллер и сбрасываем состояние поиска после закрытия диалога
      // Это нужно делать здесь, так как BlocProvider создается и уничтожается с диалогом
      // userSearchDialogController.dispose(); // Контроллер создается внутри, Flutter позаботится о нем
    });
  }

  @override
  void dispose() {
    _chatNameController.dispose();
    // _userSearchController.dispose(); // Контроллер теперь локальный для диалога
    // _chatListBloc.dispose(); // Bloc обычно не нужно диспозить здесь, если он управляется DI или деревом виджетов
    super.dispose();
  }
} 