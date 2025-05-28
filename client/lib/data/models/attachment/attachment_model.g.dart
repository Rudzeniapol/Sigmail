// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttachmentModelImpl _$$AttachmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AttachmentModelImpl(
      fileKey: json['fileKey'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
      size: (json['size'] as num).toInt(),
      presignedUrl: json['presignedUrl'] as String?,
      thumbnailKey: json['thumbnailKey'] as String?,
      thumbnailPresignedUrl: json['thumbnailPresignedUrl'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AttachmentModelImplToJson(
        _$AttachmentModelImpl instance) =>
    <String, dynamic>{
      'fileKey': instance.fileKey,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
      'size': instance.size,
      'presignedUrl': instance.presignedUrl,
      'thumbnailKey': instance.thumbnailKey,
      'thumbnailPresignedUrl': instance.thumbnailPresignedUrl,
      'width': instance.width,
      'height': instance.height,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'Image',
  AttachmentType.video: 'Video',
  AttachmentType.audio: 'Audio',
  AttachmentType.document: 'Document',
  AttachmentType.otherFile: 'OtherFile',
};
