import 'package:freezed_annotation/freezed_annotation.dart';

enum AttachmentType {
  @JsonValue('Image')
  image,
  @JsonValue('Video')
  video,
  @JsonValue('Audio')
  audio,
  @JsonValue('Document')
  document,
  @JsonValue('OtherFile')
  otherFile,
} 