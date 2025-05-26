import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

part 'presigned_url_request_model.freezed.dart';
part 'presigned_url_request_model.g.dart';

@freezed
class PresignedUrlRequestModel with _$PresignedUrlRequestModel {
  @JsonSerializable(explicitToJson: true) // Важно для вложенных enum/объектов, если они есть
  const factory PresignedUrlRequestModel({
    required String fileName,
    required int fileSize, // long на сервере, int в Dart
    String? contentType,
    required AttachmentType attachmentType,
  }) = _PresignedUrlRequestModel;

  factory PresignedUrlRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PresignedUrlRequestModelFromJson(json);
} 