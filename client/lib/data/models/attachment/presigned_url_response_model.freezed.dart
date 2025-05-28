// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presigned_url_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresignedUrlResponseModel _$PresignedUrlResponseModelFromJson(
    Map<String, dynamic> json) {
  return _PresignedUrlResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PresignedUrlResponseModel {
  String get fileKey => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get contentType => throw _privateConstructorUsedError;
  int get size =>
      throw _privateConstructorUsedError; // На сервере это long, в Dart это int
  @JsonKey(name: 'type')
  AttachmentType get attachmentType => throw _privateConstructorUsedError;
  String get presignedUploadUrl => throw _privateConstructorUsedError;

  /// Serializes this PresignedUrlResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresignedUrlResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresignedUrlResponseModelCopyWith<PresignedUrlResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresignedUrlResponseModelCopyWith<$Res> {
  factory $PresignedUrlResponseModelCopyWith(PresignedUrlResponseModel value,
          $Res Function(PresignedUrlResponseModel) then) =
      _$PresignedUrlResponseModelCopyWithImpl<$Res, PresignedUrlResponseModel>;
  @useResult
  $Res call(
      {String fileKey,
      String fileName,
      String? contentType,
      int size,
      @JsonKey(name: 'type') AttachmentType attachmentType,
      String presignedUploadUrl});
}

/// @nodoc
class _$PresignedUrlResponseModelCopyWithImpl<$Res,
        $Val extends PresignedUrlResponseModel>
    implements $PresignedUrlResponseModelCopyWith<$Res> {
  _$PresignedUrlResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresignedUrlResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = freezed,
    Object? size = null,
    Object? attachmentType = null,
    Object? presignedUploadUrl = null,
  }) {
    return _then(_value.copyWith(
      fileKey: null == fileKey
          ? _value.fileKey
          : fileKey // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
      presignedUploadUrl: null == presignedUploadUrl
          ? _value.presignedUploadUrl
          : presignedUploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresignedUrlResponseModelImplCopyWith<$Res>
    implements $PresignedUrlResponseModelCopyWith<$Res> {
  factory _$$PresignedUrlResponseModelImplCopyWith(
          _$PresignedUrlResponseModelImpl value,
          $Res Function(_$PresignedUrlResponseModelImpl) then) =
      __$$PresignedUrlResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fileKey,
      String fileName,
      String? contentType,
      int size,
      @JsonKey(name: 'type') AttachmentType attachmentType,
      String presignedUploadUrl});
}

/// @nodoc
class __$$PresignedUrlResponseModelImplCopyWithImpl<$Res>
    extends _$PresignedUrlResponseModelCopyWithImpl<$Res,
        _$PresignedUrlResponseModelImpl>
    implements _$$PresignedUrlResponseModelImplCopyWith<$Res> {
  __$$PresignedUrlResponseModelImplCopyWithImpl(
      _$PresignedUrlResponseModelImpl _value,
      $Res Function(_$PresignedUrlResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresignedUrlResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? fileName = null,
    Object? contentType = freezed,
    Object? size = null,
    Object? attachmentType = null,
    Object? presignedUploadUrl = null,
  }) {
    return _then(_$PresignedUrlResponseModelImpl(
      fileKey: null == fileKey
          ? _value.fileKey
          : fileKey // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
      presignedUploadUrl: null == presignedUploadUrl
          ? _value.presignedUploadUrl
          : presignedUploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$PresignedUrlResponseModelImpl implements _PresignedUrlResponseModel {
  const _$PresignedUrlResponseModelImpl(
      {required this.fileKey,
      required this.fileName,
      this.contentType,
      required this.size,
      @JsonKey(name: 'type') required this.attachmentType,
      required this.presignedUploadUrl});

  factory _$PresignedUrlResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresignedUrlResponseModelImplFromJson(json);

  @override
  final String fileKey;
  @override
  final String fileName;
  @override
  final String? contentType;
  @override
  final int size;
// На сервере это long, в Dart это int
  @override
  @JsonKey(name: 'type')
  final AttachmentType attachmentType;
  @override
  final String presignedUploadUrl;

  @override
  String toString() {
    return 'PresignedUrlResponseModel(fileKey: $fileKey, fileName: $fileName, contentType: $contentType, size: $size, attachmentType: $attachmentType, presignedUploadUrl: $presignedUploadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresignedUrlResponseModelImpl &&
            (identical(other.fileKey, fileKey) || other.fileKey == fileKey) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType) &&
            (identical(other.presignedUploadUrl, presignedUploadUrl) ||
                other.presignedUploadUrl == presignedUploadUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fileKey, fileName, contentType,
      size, attachmentType, presignedUploadUrl);

  /// Create a copy of PresignedUrlResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresignedUrlResponseModelImplCopyWith<_$PresignedUrlResponseModelImpl>
      get copyWith => __$$PresignedUrlResponseModelImplCopyWithImpl<
          _$PresignedUrlResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresignedUrlResponseModelImplToJson(
      this,
    );
  }
}

abstract class _PresignedUrlResponseModel implements PresignedUrlResponseModel {
  const factory _PresignedUrlResponseModel(
          {required final String fileKey,
          required final String fileName,
          final String? contentType,
          required final int size,
          @JsonKey(name: 'type') required final AttachmentType attachmentType,
          required final String presignedUploadUrl}) =
      _$PresignedUrlResponseModelImpl;

  factory _PresignedUrlResponseModel.fromJson(Map<String, dynamic> json) =
      _$PresignedUrlResponseModelImpl.fromJson;

  @override
  String get fileKey;
  @override
  String get fileName;
  @override
  String? get contentType;
  @override
  int get size; // На сервере это long, в Dart это int
  @override
  @JsonKey(name: 'type')
  AttachmentType get attachmentType;
  @override
  String get presignedUploadUrl;

  /// Create a copy of PresignedUrlResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresignedUrlResponseModelImplCopyWith<_$PresignedUrlResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
