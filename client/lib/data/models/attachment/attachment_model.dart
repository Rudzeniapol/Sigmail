import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

part 'attachment_model.freezed.dart';
part 'attachment_model.g.dart';

@freezed
class AttachmentModel with _$AttachmentModel {
  @JsonSerializable(explicitToJson: true)
  const factory AttachmentModel({
    required String fileKey,
    required String fileName,
    required String contentType,
    required AttachmentType type,
    required int size,
    String? presignedUrl,
    String? thumbnailKey,
    String? thumbnailPresignedUrl,
    int? width,
    int? height,
  }) = _AttachmentModel;

  factory AttachmentModel.fromJson(Map<String, dynamic> json) => _$AttachmentModelFromJson(json);
}