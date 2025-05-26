import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_request_model.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_response_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class GetPresignedUploadUrlUseCase implements UseCase<PresignedUrlResponseModel, PresignedUrlRequestModel> {
  final ChatRepository _repository;

  GetPresignedUploadUrlUseCase(this._repository);

  @override
  Future<Either<Failure, PresignedUrlResponseModel>> call(PresignedUrlRequestModel params) async {
    return await _repository.getPresignedUploadUrl(params);
  }
} 