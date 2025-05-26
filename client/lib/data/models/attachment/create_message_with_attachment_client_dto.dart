import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

part 'create_message_with_attachment_client_dto.freezed.dart';
part 'create_message_with_attachment_client_dto.g.dart';

@freezed
class CreateMessageWithAttachmentClientDto with _$CreateMessageWithAttachmentClientDto {
  @JsonSerializable(explicitToJson: true)
  const factory CreateMessageWithAttachmentClientDto({
    required String chatId,
    required String fileKey,
    required String fileName,
    required String contentType,
    required int size, // long -> int
    required AttachmentType attachmentType,
    int? width,
    int? height,
    String? thumbnailKey,
  }) = _CreateMessageWithAttachmentClientDto;

  factory CreateMessageWithAttachmentClientDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMessageWithAttachmentClientDtoFromJson(json);
} 