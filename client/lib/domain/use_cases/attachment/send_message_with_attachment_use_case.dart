import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/attachment/create_message_with_attachment_client_dto.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class SendMessageWithAttachmentUseCase implements UseCase<MessageModel, CreateMessageWithAttachmentClientDto> {
  final ChatRepository _repository;

  SendMessageWithAttachmentUseCase(this._repository);

  @override
  Future<Either<Failure, MessageModel>> call(CreateMessageWithAttachmentClientDto params) async {
    return await _repository.sendMessageWithAttachment(params);
  }
} 