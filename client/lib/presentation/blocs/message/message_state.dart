import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:meta/meta.dart'; // Для @immutable

@immutable
abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

// Состояние для индикации загрузки файла
class MessageSendingAttachment extends MessageState {
  final List<MessageModel> messages; // Можно передавать текущий список сообщений, чтобы UI не мигал
  final bool hasReachedMax; // И флаг пагинации

  const MessageSendingAttachment(this.messages, this.hasReachedMax);

  @override
  List<Object> get props => [messages, hasReachedMax];
}

class MessageLoaded extends MessageState {
  final List<MessageModel> messages;
  final bool hasReachedMax; // Для пагинации

  const MessageLoaded(this.messages, {this.hasReachedMax = false});

  @override
  List<Object> get props => [messages, hasReachedMax];

  MessageLoaded copyWith({
    List<MessageModel>? messages,
    bool? hasReachedMax,
  }) {
    return MessageLoaded(
      messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object> get props => [message];
} 