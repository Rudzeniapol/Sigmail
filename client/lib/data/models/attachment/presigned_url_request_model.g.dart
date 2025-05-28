// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presigned_url_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresignedUrlRequestModelImpl _$$PresignedUrlRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PresignedUrlRequestModelImpl(
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      contentType: json['contentType'] as String?,
      attachmentType:
          $enumDecode(_$AttachmentTypeEnumMap, json['attachmentType']),
    );

Map<String, dynamic> _$$PresignedUrlRequestModelImplToJson(
        _$PresignedUrlRequestModelImpl instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'contentType': instance.contentType,
      'attachmentType': _$AttachmentTypeEnumMap[instance.attachmentType]!,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'Image',
  AttachmentType.video: 'Video',
  AttachmentType.audio: 'Audio',
  AttachmentType.document: 'Document',
  AttachmentType.otherFile: 'OtherFile',
};
