// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateAttachmentModelImpl _$$CreateAttachmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateAttachmentModelImpl(
      fileKey: json['fileKey'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
      size: (json['size'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$$CreateAttachmentModelImplToJson(
        _$CreateAttachmentModelImpl instance) =>
    <String, dynamic>{
      'fileKey': instance.fileKey,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
      'size': instance.size,
      'thumbnailUrl': instance.thumbnailUrl,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'Image',
  AttachmentType.video: 'Video',
  AttachmentType.audio: 'Audio',
  AttachmentType.document: 'Document',
  AttachmentType.otherFile: 'OtherFile',
};
