import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatModel> chats;
  // Можно добавить флаги hasReachedMax для пагинации, если используется бесконечная прокрутка
  // final bool hasReachedMax;

  const ChatListLoaded(this.chats /*, {this.hasReachedMax = false}*/);

  @override
  List<Object?> get props => [chats /*, hasReachedMax*/];

  ChatListLoaded copyWith({
    List<ChatModel>? chats,
    // bool? hasReachedMax,
  }) {
    return ChatListLoaded(
      chats ?? this.chats,
      // hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ChatListCreating extends ChatListState {} // Состояние во время создания нового чата

class ChatListCreated extends ChatListState {
   final ChatModel newChat;
   const ChatListCreated(this.newChat);

   @override
  List<Object?> get props => [newChat];
} // Состояние после успешного создания нового чата

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
} 