import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/data_sources/realtime/chat_realtime_data_source.dart';
import 'package:sigmail_client/data/models/typing/typing_event_model.dart';
import 'package:sigmail_client/domain/entities/typing_info_entity.dart';

part 'typing_status_event.dart';
part 'typing_status_state.dart';

class TypingStatusBloc extends Bloc<TypingStatusEvent, TypingStatusState> {
  final ChatRealtimeDataSource _chatRealtimeDataSource;
  StreamSubscription<TypingEventModel>? _typingStatusSubscription;

  TypingStatusBloc(this._chatRealtimeDataSource)
      : super(const TypingStatusInitial()) {
    on<LocalUserStartedTyping>(_onLocalUserStartedTyping);
    on<LocalUserStoppedTyping>(_onLocalUserStoppedTyping);
    on<_RemoteUserTypingStatusChanged>(_onRemoteUserTypingStatusChanged);

    _subscribeToTypingEvents();
  }

  void _subscribeToTypingEvents() {
    _typingStatusSubscription = _chatRealtimeDataSource.typingStatusEvents.listen(
      (eventModel) {
        add(_RemoteUserTypingStatusChanged(eventModel));
      },
      onError: (error) {
        // Handle error, maybe log it or emit an error state
        print('Error in typing status stream: $error');
      },
    );
  }

  Future<void> _onLocalUserStartedTyping(
    LocalUserStartedTyping event,
    Emitter<TypingStatusState> emit,
  ) async {
    await _chatRealtimeDataSource.sendUserIsTyping(event.chatId);
    // Мы не обновляем состояние немедленно для локального пользователя,
    // так как сервер не будет отправлять событие "UserTypingInChat" обратно тому же пользователю.
    // Если UI должен немедленно отразить "You are typing...", это можно сделать локально в UI,
    // либо изменить логику здесь (но это усложнит синхронизацию).
  }

  Future<void> _onLocalUserStoppedTyping(
    LocalUserStoppedTyping event,
    Emitter<TypingStatusState> emit,
  ) async {
    await _chatRealtimeDataSource.sendUserStoppedTyping(event.chatId);
    // Аналогично, не обновляем состояние немедленно.
  }

  void _onRemoteUserTypingStatusChanged(
    _RemoteUserTypingStatusChanged event,
    Emitter<TypingStatusState> emit,
  ) {
    final eventModel = event.eventModel;
    final chatId = eventModel.chatId;
    final typingUser = UserTypingInfo(userId: eventModel.userId, username: eventModel.username);

    // Создаем копию текущей карты состояний
    final Map<String, Set<UserTypingInfo>> newTypingUsersByChatId = Map.from(state.typingUsersByChatId);
    
    // Получаем или создаем множество для текущего чата
    final Set<UserTypingInfo> usersTypingInThisChat = Set.from(newTypingUsersByChatId[chatId] ?? {});

    if (eventModel.isTyping) {
      usersTypingInThisChat.add(typingUser);
    } else {
      usersTypingInThisChat.remove(typingUser);
    }

    // Обновляем карту для этого чата
    if (usersTypingInThisChat.isEmpty) {
      newTypingUsersByChatId.remove(chatId); // Удаляем запись, если никто не печатает
    } else {
      newTypingUsersByChatId[chatId] = usersTypingInThisChat;
    }
    
    emit(TypingStatusUpdated(newTypingUsersByChatId));
  }

  @override
  Future<void> close() {
    _typingStatusSubscription?.cancel();
    return super.close();
  }
} 