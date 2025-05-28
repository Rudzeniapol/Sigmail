// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_message_with_attachment_client_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateMessageWithAttachmentClientDtoImpl
    _$$CreateMessageWithAttachmentClientDtoImplFromJson(
            Map<String, dynamic> json) =>
        _$CreateMessageWithAttachmentClientDtoImpl(
          chatId: json['chatId'] as String,
          fileKey: json['fileKey'] as String,
          fileName: json['fileName'] as String,
          contentType: json['contentType'] as String,
          size: (json['size'] as num).toInt(),
          attachmentType:
              $enumDecode(_$AttachmentTypeEnumMap, json['attachmentType']),
          width: (json['width'] as num?)?.toInt(),
          height: (json['height'] as num?)?.toInt(),
          thumbnailKey: json['thumbnailKey'] as String?,
        );

Map<String, dynamic> _$$CreateMessageWithAttachmentClientDtoImplToJson(
        _$CreateMessageWithAttachmentClientDtoImpl instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'fileKey': instance.fileKey,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'size': instance.size,
      'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
      'width': instance.width,
      'height': instance.height,
      'thumbnailKey': instance.thumbnailKey,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'Image',
  AttachmentType.video: 'Video',
  AttachmentType.audio: 'Audio',
  AttachmentType.document: 'Document',
  AttachmentType.otherFile: 'OtherFile',
};
