import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
// import 'package:sigmail_client/core/use_case/use_case.dart';

class SendMessageUseCase extends UseCase<MessageModel, CreateMessageModel> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageModel>> call(CreateMessageModel params) async {
    return await repository.sendMessage(params);
  }
} 