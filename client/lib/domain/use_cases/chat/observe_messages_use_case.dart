import 'package:equatable/equatable.dart';
import 'package:sigmail_client/core/use_case.dart'; // Исправленный импорт
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

// Обновляем на implements StreamUseCase
class ObserveMessagesUseCase implements StreamUseCase<MessageModel, ObserveMessagesParams> {
  final ChatRepository repository;

  ObserveMessagesUseCase(this.repository);

  @override
  Stream<MessageModel> call(ObserveMessagesParams params) {
    return repository.observeMessages(params.chatId);
  }
}

class ObserveMessagesParams extends Equatable {
  final String chatId;

  const ObserveMessagesParams(this.chatId);

  @override
  List<Object> get props => [chatId];
} 