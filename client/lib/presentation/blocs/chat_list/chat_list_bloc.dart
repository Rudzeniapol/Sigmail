import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/domain/use_cases/chat/create_chat_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/get_chats_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_chat_details_use_case.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_event.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChatsUseCase;
  final CreateChatUseCase _createChatUseCase;
  final ObserveChatDetailsUseCase _observeChatDetailsUseCase;

  // Для отслеживания подписок на обновления чатов, чтобы их можно было отменить
  final Map<String, StreamSubscription> _chatUpdateSubscriptions = {};

  ChatListBloc({
    required GetChatsUseCase getChatsUseCase,
    required CreateChatUseCase createChatUseCase,
    required ObserveChatDetailsUseCase observeChatDetailsUseCase,
  })  : _getChatsUseCase = getChatsUseCase,
        _createChatUseCase = createChatUseCase,
        _observeChatDetailsUseCase = observeChatDetailsUseCase,
        super(ChatListInitial()) {
    on<LoadChatList>(_onLoadChatList);
    on<CreateNewChat>(_onCreateNewChat);
    on<InternalChatUpdated>(_onInternalChatUpdated);
  }

  Future<void> _onLoadChatList(LoadChatList event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());
    final result = await _getChatsUseCase.call(GetChatsParams(pageNumber: event.pageNumber, pageSize: event.pageSize));
    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (chats) {
        emit(ChatListLoaded(chats));
        _subscribeToChatUpdates(chats, emit);
      }
    );
  }

  Future<void> _onCreateNewChat(CreateNewChat event, Emitter<ChatListState> emit) async {
    emit(ChatListCreating());
    final result = await _createChatUseCase.call(event.createChatModel);
    result.fold(
      (failure) => emit(ChatListError(failure.message)), 
      (newChat) {
        emit(ChatListCreated(newChat)); // Уведомляем UI, что чат создан
        // Добавляем новый чат в текущий список, если он уже загружен
        if (state is ChatListLoaded) {
          final currentChats = (state as ChatListLoaded).chats;
          final updatedChats = List<ChatModel>.from(currentChats)..insert(0, newChat);
          emit(ChatListLoaded(updatedChats)); 
          _subscribeToChatUpdates([newChat], emit); // Подписываемся на обновления нового чата
        } else {
          // Если список еще не был загружен, просто загружаем его (включая новый чат)
          add(const LoadChatList());
        }
      }
    );
  }

  void _onInternalChatUpdated(InternalChatUpdated event, Emitter<ChatListState> emit) {
    if (state is ChatListLoaded) {
      final currentChats = (state as ChatListLoaded).chats;
      final index = currentChats.indexWhere((chat) => chat.id == event.updatedChat.id);
      if (index != -1) {
        final updatedChats = List<ChatModel>.from(currentChats);
        updatedChats[index] = event.updatedChat;
        emit(ChatListLoaded(updatedChats));
      } else {
        // Если чат не найден (маловероятно, но возможно), добавляем его
        final updatedChats = List<ChatModel>.from(currentChats)..insert(0, event.updatedChat);
         emit(ChatListLoaded(updatedChats));
        _subscribeToChatUpdates([event.updatedChat], emit); // И подписываемся
      }
    }
  }

  void _subscribeToChatUpdates(List<ChatModel> chats, Emitter<ChatListState> emit) {
    for (var chat in chats) {
      // Отписываемся от предыдущей подписки, если она есть для этого чата
      _chatUpdateSubscriptions[chat.id]?.cancel();
      // Подписываемся на обновления для каждого чата
      _chatUpdateSubscriptions[chat.id] = _observeChatDetailsUseCase
          .call(ObserveChatDetailsParams(chat.id))
          .listen((updatedChat) {
        add(InternalChatUpdated(updatedChat));
      }, onError: (error) {
        // Можно добавить обработку ошибок стрима, если нужно
        print('[ChatListBloc] Error observing chat details for ${chat.id}: $error');
        // emit(ChatListError('Ошибка наблюдения за чатом: $error'));
      });
    }
  }

  @override
  Future<void> close() {
    _chatUpdateSubscriptions.values.forEach((sub) => sub.cancel());
    _chatUpdateSubscriptions.clear();
    return super.close();
  }
} 