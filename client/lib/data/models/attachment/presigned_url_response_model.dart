import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

part 'presigned_url_response_model.freezed.dart';
part 'presigned_url_response_model.g.dart';

@freezed
class PresignedUrlResponseModel with _$PresignedUrlResponseModel {
   @JsonSerializable(explicitToJson: true)
   const factory PresignedUrlResponseModel({
    required String fileKey,
    required String fileName,
    String? contentType,
    required int size, // На сервере это long, в Dart это int
    @JsonKey(name: 'type')
    required AttachmentType attachmentType,
    required String presignedUploadUrl,
  }) = _PresignedUrlResponseModel;

  factory PresignedUrlResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PresignedUrlResponseModelFromJson(json);
} 