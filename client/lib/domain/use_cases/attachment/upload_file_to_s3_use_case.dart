import 'package:dartz/dartz.dart';
import 'package:cross_file/cross_file.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';

class UploadFileToS3Params {
  final String presignedUrl;
  final XFile file;
  final String? contentType;

  UploadFileToS3Params({
    required this.presignedUrl,
    required this.file,
    this.contentType,
  });
}

class UploadFileToS3UseCase implements UseCase<void, UploadFileToS3Params> {
  final ChatRepository _repository;

  UploadFileToS3UseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UploadFileToS3Params params) async {
    return await _repository.uploadFileToS3(params.presignedUrl, params.file, params.contentType);
  }
} 