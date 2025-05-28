import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/reaction/reaction_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class RemoveReactionUseCase implements UseCase<List<ReactionModel>, RemoveReactionParams> {
  final ChatRepository repository;

  RemoveReactionUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReactionModel>>> call(RemoveReactionParams params) async {
    return await repository.removeReaction(params.messageId, params.emoji);
  }
}

class RemoveReactionParams {
  final String messageId;
  final String emoji;

  RemoveReactionParams({required this.messageId, required this.emoji});
} 