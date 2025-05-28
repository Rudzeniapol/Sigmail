import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/reaction/reaction_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class AddReactionUseCase implements UseCase<List<ReactionModel>, AddReactionParams> {
  final ChatRepository repository;

  AddReactionUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReactionModel>>> call(AddReactionParams params) async {
    return await repository.addReaction(params.messageId, params.emoji);
  }
}

class AddReactionParams {
  final String messageId;
  final String emoji;

  AddReactionParams({required this.messageId, required this.emoji});
} 