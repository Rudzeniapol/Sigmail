// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttachmentModel _$AttachmentModelFromJson(Map<String, dynamic> json) {
  return _AttachmentModel.fromJson(json);
}

/// @nodoc
mixin _$AttachmentModel {
  String get fileKey => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  AttachmentType get type => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String? get presignedUrl => throw _privateConstructorUsedError;
  String? get thumbnailKey => throw _privateConstructorUsedError;
  String? get thumbnailPresignedUrl => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;

  /// Serializes this AttachmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttachmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttachmentModelCopyWith<AttachmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttachmentModelCopyWith<$Res> {
  factory $AttachmentModelCopyWith(
    AttachmentModel value,
    $Res Function(AttachmentModel) then,
  ) = _$AttachmentModelCopyWithImpl<$Res, AttachmentModel>;
  @useResult
  $Res call({
    String fileKey,
    String fileName,
    String contentType,
    AttachmentType type,
    int size,
    String? presignedUrl,
    String? thumbnailKey,
    String? thumbnailPresignedUrl,
    int? width,
    int? height,
  });
}

/// @nodoc
class _$AttachmentModelCopyWithImpl<$Res, $Val extends AttachmentModel>
    implements $AttachmentModelCopyWith<$Res> {
  _$AttachmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttachmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? type = null,
    Object? size = null,
    Object? presignedUrl = freezed,
    Object? thumbnailKey = freezed,
    Object? thumbnailPresignedUrl = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as AttachmentType,
            size:
                null == size
                    ? _value.size
                    : size // ignore: cast_nullable_to_non_nullable
                        as int,
            presignedUrl:
                freezed == presignedUrl
                    ? _value.presignedUrl
                    : presignedUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            thumbnailKey:
                freezed == thumbnailKey
                    ? _value.thumbnailKey
                    : thumbnailKey // ignore: cast_nullable_to_non_nullable
                        as String?,
            thumbnailPresignedUrl:
                freezed == thumbnailPresignedUrl
                    ? _value.thumbnailPresignedUrl
                    : thumbnailPresignedUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttachmentModelImplCopyWith<$Res>
    implements $AttachmentModelCopyWith<$Res> {
  factory _$$AttachmentModelImplCopyWith(
    _$AttachmentModelImpl value,
    $Res Function(_$AttachmentModelImpl) then,
  ) = __$$AttachmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fileKey,
    String fileName,
    String contentType,
    AttachmentType type,
    int size,
    String? presignedUrl,
    String? thumbnailKey,
    String? thumbnailPresignedUrl,
    int? width,
    int? height,
  });
}

/// @nodoc
class __$$AttachmentModelImplCopyWithImpl<$Res>
    extends _$AttachmentModelCopyWithImpl<$Res, _$AttachmentModelImpl>
    implements _$$AttachmentModelImplCopyWith<$Res> {
  __$$AttachmentModelImplCopyWithImpl(
    _$AttachmentModelImpl _value,
    $Res Function(_$AttachmentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = null,
    Object? type = null,
    Object? size = null,
    Object? presignedUrl = freezed,
    Object? thumbnailKey = freezed,
    Object? thumbnailPresignedUrl = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(
      _$AttachmentModelImpl(
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
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as AttachmentType,
        size:
            null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                    as int,
        presignedUrl:
            freezed == presignedUrl
                ? _value.presignedUrl
                : presignedUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        thumbnailKey:
            freezed == thumbnailKey
                ? _value.thumbnailKey
                : thumbnailKey // ignore: cast_nullable_to_non_nullable
                    as String?,
        thumbnailPresignedUrl:
            freezed == thumbnailPresignedUrl
                ? _value.thumbnailPresignedUrl
                : thumbnailPresignedUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
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
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$AttachmentModelImpl implements _AttachmentModel {
  const _$AttachmentModelImpl({
    required this.fileKey,
    required this.fileName,
    required this.contentType,
    required this.type,
    required this.size,
    this.presignedUrl,
    this.thumbnailKey,
    this.thumbnailPresignedUrl,
    this.width,
    this.height,
  });

  factory _$AttachmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttachmentModelImplFromJson(json);

  @override
  final String fileKey;
  @override
  final String fileName;
  @override
  final String contentType;
  @override
  final AttachmentType type;
  @override
  final int size;
  @override
  final String? presignedUrl;
  @override
  final String? thumbnailKey;
  @override
  final String? thumbnailPresignedUrl;
  @override
  final int? width;
  @override
  final int? height;

  @override
  String toString() {
    return 'AttachmentModel(fileKey: $fileKey, fileName: $fileName, contentType: $contentType, type: $type, size: $size, presignedUrl: $presignedUrl, thumbnailKey: $thumbnailKey, thumbnailPresignedUrl: $thumbnailPresignedUrl, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttachmentModelImpl &&
            (identical(other.fileKey, fileKey) || other.fileKey == fileKey) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.presignedUrl, presignedUrl) ||
                other.presignedUrl == presignedUrl) &&
            (identical(other.thumbnailKey, thumbnailKey) ||
                other.thumbnailKey == thumbnailKey) &&
            (identical(other.thumbnailPresignedUrl, thumbnailPresignedUrl) ||
                other.thumbnailPresignedUrl == thumbnailPresignedUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fileKey,
    fileName,
    contentType,
    type,
    size,
    presignedUrl,
    thumbnailKey,
    thumbnailPresignedUrl,
    width,
    height,
  );

  /// Create a copy of AttachmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttachmentModelImplCopyWith<_$AttachmentModelImpl> get copyWith =>
      __$$AttachmentModelImplCopyWithImpl<_$AttachmentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttachmentModelImplToJson(this);
  }
}

abstract class _AttachmentModel implements AttachmentModel {
  const factory _AttachmentModel({
    required final String fileKey,
    required final String fileName,
    required final String contentType,
    required final AttachmentType type,
    required final int size,
    final String? presignedUrl,
    final String? thumbnailKey,
    final String? thumbnailPresignedUrl,
    final int? width,
    final int? height,
  }) = _$AttachmentModelImpl;

  factory _AttachmentModel.fromJson(Map<String, dynamic> json) =
      _$AttachmentModelImpl.fromJson;

  @override
  String get fileKey;
  @override
  String get fileName;
  @override
  String get contentType;
  @override
  AttachmentType get type;
  @override
  int get size;
  @override
  String? get presignedUrl;
  @override
  String? get thumbnailKey;
  @override
  String? get thumbnailPresignedUrl;
  @override
  int? get width;
  @override
  int? get height;

  /// Create a copy of AttachmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttachmentModelImplCopyWith<_$AttachmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
