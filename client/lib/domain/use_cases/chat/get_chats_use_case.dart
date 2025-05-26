import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
// import 'package:sigmail_client/core/use_case/use_case.dart'; // Для базового UseCase и NoParams/Params

// Параметры для GetChatsUseCase, если нужна пагинация
class GetChatsParams extends Equatable {
  final int pageNumber;
  final int pageSize;

  const GetChatsParams({this.pageNumber = 1, this.pageSize = 20});

  @override
  List<Object> get props => [pageNumber, pageSize];
}

class GetChatsUseCase extends UseCase<List<ChatModel>, GetChatsParams> {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatModel>>> call(GetChatsParams params) async {
    return await repository.getChats(pageNumber: params.pageNumber, pageSize: params.pageSize);
  }
} 