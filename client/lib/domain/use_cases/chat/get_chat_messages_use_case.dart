import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
// import 'package:sigmail_client/core/use_case/use_case.dart';

class GetChatMessagesUseCase extends UseCase<List<MessageModel>, GetChatMessagesParams> {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageModel>>> call(GetChatMessagesParams params) async {
    return await repository.getChatMessages(
      params.chatId, 
      pageNumber: params.pageNumber, 
      pageSize: params.pageSize
    );
  }
}

class GetChatMessagesParams extends Equatable {
  final String chatId;
  final int pageNumber;
  final int pageSize;

  const GetChatMessagesParams({
    required this.chatId,
    this.pageNumber = 1,
    this.pageSize = 50, // Соответствует _defaultPageSize в MessageBloc
  });

  @override
  List<Object> get props => [chatId, pageNumber, pageSize];
} 