part of 'typing_status_bloc.dart';

sealed class TypingStatusEvent extends Equatable {
  const TypingStatusEvent();

  @override
  List<Object> get props => [];
}

class LocalUserStartedTyping extends TypingStatusEvent {
  final String chatId;

  const LocalUserStartedTyping(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class LocalUserStoppedTyping extends TypingStatusEvent {
  final String chatId;

  const LocalUserStoppedTyping(this.chatId);

  @override
  List<Object> get props => [chatId];
}

// Внутреннее событие для обработки данных от ChatRealtimeDataSource
class _RemoteUserTypingStatusChanged extends TypingStatusEvent {
  final TypingEventModel eventModel;

  const _RemoteUserTypingStatusChanged(this.eventModel);

  @override
  List<Object> get props => [eventModel];
} 