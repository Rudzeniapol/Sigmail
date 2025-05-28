import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase implements UseCase<void, MarkMessagesAsReadParams> {
  final ChatRepository _repository;

  MarkMessagesAsReadUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    return await _repository.markMessagesAsRead(params.chatId);
  }
}

class MarkMessagesAsReadParams {
  final String chatId;

  MarkMessagesAsReadParams(this.chatId);
} 