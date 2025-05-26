// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presigned_url_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresignedUrlResponseModelImpl _$$PresignedUrlResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$PresignedUrlResponseModelImpl(
  fileKey: json['fileKey'] as String,
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String?,
  size: (json['size'] as num).toInt(),
  attachmentType: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
  presignedUploadUrl: json['presignedUploadUrl'] as String,
);

Map<String, dynamic> _$$PresignedUrlResponseModelImplToJson(
  _$PresignedUrlResponseModelImpl instance,
) => <String, dynamic>{
  'fileKey': instance.fileKey,
  'fileName': instance.fileName,
  'contentType': instance.contentType,
  'size': instance.size,
  'type': _$AttachmentTypeEnumMap[instance.attachmentType]!,
  'presignedUploadUrl': instance.presignedUploadUrl,
};

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'Image',
  AttachmentType.video: 'Video',
  AttachmentType.audio: 'Audio',
  AttachmentType.document: 'Document',
  AttachmentType.otherFile: 'OtherFile',
};
