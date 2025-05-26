// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_message_with_attachment_client_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateMessageWithAttachmentClientDto
_$CreateMessageWithAttachmentClientDtoFromJson(Map<String, dynamic> json) {
  return _CreateMessageWithAttachmentClientDto.fromJson(json);
}

/// @nodoc
mixin _$CreateMessageWithAttachmentClientDto {
  String get chatId => throw _privateConstructorUsedError;
  String get fileKey => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError; // long -> int
  AttachmentType get attachmentType => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String? get thumbnailKey => throw _privateConstructorUsedError;

  /// Serializes this CreateMessageWithAttachmentClientDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateMessageWithAttachmentClientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateMessageWithAttachmentClientDtoCopyWith<
    CreateMessageWithAttachmentClientDto
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMessageWithAttachmentClientDtoCopyWith<$Res> {
  factory $CreateMessageWithAttachmentClientDtoCopyWith(
    CreateMessageWithAttachmentClientDto value,
    $Res Function(CreateMessageWithAttachmentClientDto) then,
  ) =
      _$CreateMessageWithAttachmentClientDtoCopyWithImpl<
        $Res,
        CreateMessageWithAttachmentClientDto
      >;
  @useResult
  $Res call({
    String chatId,
    String fileKey,
    String fileName,
    String contentType,
    int size,
    AttachmentType attachmentType,
    int? width,
    int? height,
    String? thumbnailKey,
  });
}

/// @nodoc
class _$CreateMessageWithAttachmentClientDtoCopyWithImpl<
  $Res,
  $Val extends CreateMessageWithAttachmentClientDto
>
    implements $CreateMessageWithAttachmentClientDtoCopyWith<$Res> {
  _$CreateMessageWithAttachmentClientDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMessageWithAttachmentClientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = null,
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? size = null,
    Object? attachmentType = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? thumbnailKey = freezed,
  }) {
    return _then(
      _value.copyWith(
            chatId:
                null == chatId
                    ? _value.chatId
                    : chatId // ignore: cast_nullable_to_non_nullable
                        as String,
            fileKey:
                null == fileKey
                    ? _value.fileKey
                    : fileKey // ignore: cast_nullable_to_non_nullable
                        as String,
            fileName:
                null == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
                        as String,
            contentType:
                null == contentType
                    ? _value.contentType
                    : contentType // ignore: cast_nullable_to_non_nullable
                        as String,
            size:
                null == size
                    ? _value.size
                    : size // ignore: cast_nullable_to_non_nullable
                        as int,
            attachmentType:
                null == attachmentType
                    ? _value.attachmentType
                    : attachmentType // ignore: cast_nullable_to_non_nullable
                        as AttachmentType,
            width:
                freezed == width
                    ? _value.width
                    : width // ignore: cast_nullable_to_non_nullable
                        as int?,
            height:
                freezed == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as int?,
            thumbnailKey:
                freezed == thumbnailKey
                    ? _value.thumbnailKey
                    : thumbnailKey // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateMessageWithAttachmentClientDtoImplCopyWith<$Res>
    implements $CreateMessageWithAttachmentClientDtoCopyWith<$Res> {
  factory _$$CreateMessageWithAttachmentClientDtoImplCopyWith(
    _$CreateMessageWithAttachmentClientDtoImpl value,
    $Res Function(_$CreateMessageWithAttachmentClientDtoImpl) then,
  ) = __$$CreateMessageWithAttachmentClientDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String chatId,
    String fileKey,
    String fileName,
    String contentType,
    int size,
    AttachmentType attachmentType,
    int? width,
    int? height,
    String? thumbnailKey,
  });
}

/// @nodoc
class __$$CreateMessageWithAttachmentClientDtoImplCopyWithImpl<$Res>
    extends
        _$CreateMessageWithAttachmentClientDtoCopyWithImpl<
          $Res,
          _$CreateMessageWithAttachmentClientDtoImpl
        >
    implements _$$CreateMessageWithAttachmentClientDtoImplCopyWith<$Res> {
  __$$CreateMessageWithAttachmentClientDtoImplCopyWithImpl(
    _$CreateMessageWithAttachmentClientDtoImpl _value,
    $Res Function(_$CreateMessageWithAttachmentClientDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateMessageWithAttachmentClientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = null,
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? size = null,
    Object? attachmentType = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? thumbnailKey = freezed,
  }) {
    return _then(
      _$CreateMessageWithAttachmentClientDtoImpl(
        chatId:
            null == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                    as String,
        fileKey:
            null == fileKey
                ? _value.fileKey
                : fileKey // ignore: cast_nullable_to_non_nullable
                    as String,
        fileName:
            null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                    as String,
        contentType:
            null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                    as String,
        size:
            null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                    as int,
        attachmentType:
            null == attachmentType
                ? _value.attachmentType
                : attachmentType // ignore: cast_nullable_to_non_nullable
                    as AttachmentType,
        width:
            freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                    as int?,
        height:
            freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int?,
        thumbnailKey:
            freezed == thumbnailKey
                ? _value.thumbnailKey
                : thumbnailKey // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CreateMessageWithAttachmentClientDtoImpl
    implements _CreateMessageWithAttachmentClientDto {
  const _$CreateMessageWithAttachmentClientDtoImpl({
    required this.chatId,
    required this.fileKey,
    required this.fileName,
    required this.contentType,
    required this.size,
    required this.attachmentType,
    this.width,
    this.height,
    this.thumbnailKey,
  });

  factory _$CreateMessageWithAttachmentClientDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CreateMessageWithAttachmentClientDtoImplFromJson(json);

  @override
  final String chatId;
  @override
  final String fileKey;
  @override
  final String fileName;
  @override
  final String contentType;
  @override
  final int size;
  // long -> int
  @override
  final AttachmentType attachmentType;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? thumbnailKey;

  @override
  String toString() {
    return 'CreateMessageWithAttachmentClientDto(chatId: $chatId, fileKey: $fileKey, fileName: $fileName, contentType: $contentType, size: $size, attachmentType: $attachmentType, width: $width, height: $height, thumbnailKey: $thumbnailKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMessageWithAttachmentClientDtoImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.fileKey, fileKey) || other.fileKey == fileKey) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.thumbnailKey, thumbnailKey) ||
                other.thumbnailKey == thumbnailKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chatId,
    fileKey,
    fileName,
    contentType,
    size,
    attachmentType,
    width,
    height,
    thumbnailKey,
  );

  /// Create a copy of CreateMessageWithAttachmentClientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMessageWithAttachmentClientDtoImplCopyWith<
    _$CreateMessageWithAttachmentClientDtoImpl
  >
  get copyWith => __$$CreateMessageWithAttachmentClientDtoImplCopyWithImpl<
    _$CreateMessageWithAttachmentClientDtoImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateMessageWithAttachmentClientDtoImplToJson(this);
  }
}

abstract class _CreateMessageWithAttachmentClientDto
    implements CreateMessageWithAttachmentClientDto {
  const factory _CreateMessageWithAttachmentClientDto({
    required final String chatId,
    required final String fileKey,
    required final String fileName,
    required final String contentType,
    required final int size,
    required final AttachmentType attachmentType,
    final int? width,
    final int? height,
    final String? thumbnailKey,
  }) = _$CreateMessageWithAttachmentClientDtoImpl;

  factory _CreateMessageWithAttachmentClientDto.fromJson(
    Map<String, dynamic> json,
  ) = _$CreateMessageWithAttachmentClientDtoImpl.fromJson;

  @override
  String get chatId;
  @override
  String get fileKey;
  @override
  String get fileName;
  @override
  String get contentType;
  @override
  int get size; // long -> int
  @override
  AttachmentType get attachmentType;
  @override
  int? get width;
  @override
  int? get height;
  @override
  String? get thumbnailKey;

  /// Create a copy of CreateMessageWithAttachmentClientDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMessageWithAttachmentClientDtoImplCopyWith<
    _$CreateMessageWithAttachmentClientDtoImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
