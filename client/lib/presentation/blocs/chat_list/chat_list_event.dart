import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

// Событие для запроса первоначальной загрузки списка чатов
class LoadChatList extends ChatListEvent {
  final int pageNumber;
  final int pageSize;

  const LoadChatList({this.pageNumber = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

// Событие, когда новый чат был создан (например, через CreateChatUseCase)
class ChatCreated extends ChatListEvent {
  final ChatModel newChat;

  const ChatCreated(this.newChat);

  @override
  List<Object?> get props => [newChat];
}

// Событие для создания нового чата (инициируется пользователем)
class CreateNewChat extends ChatListEvent {
  final CreateChatModel createChatModel;

  const CreateNewChat(this.createChatModel);

  @override
  List<Object?> get props => [createChatModel];
}

// Внутреннее событие, когда информация о чате обновилась через Stream
class InternalChatUpdated extends ChatListEvent {
  final ChatModel updatedChat;

  const InternalChatUpdated(this.updatedChat);

  @override
  List<Object?> get props => [updatedChat];
}

// TODO: Добавить события для пагинации (загрузить следующую страницу), 
// обновления (pull-to-refresh) и т.д., если это необходимо. 