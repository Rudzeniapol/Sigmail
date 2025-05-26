import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
// import 'package:sigmail_client/core/use_case/use_case.dart';

class CreateChatUseCase extends UseCase<ChatModel, CreateChatModel> {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  @override
  Future<Either<Failure, ChatModel>> call(CreateChatModel params) async {
    return await repository.createChat(params);
  }
} 