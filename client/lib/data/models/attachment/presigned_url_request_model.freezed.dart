// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presigned_url_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresignedUrlRequestModel _$PresignedUrlRequestModelFromJson(
    Map<String, dynamic> json) {
  return _PresignedUrlRequestModel.fromJson(json);
}

/// @nodoc
mixin _$PresignedUrlRequestModel {
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize =>
      throw _privateConstructorUsedError; // long на сервере, int в Dart
  String? get contentType => throw _privateConstructorUsedError;
  AttachmentType get attachmentType => throw _privateConstructorUsedError;

  /// Serializes this PresignedUrlRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresignedUrlRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresignedUrlRequestModelCopyWith<PresignedUrlRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresignedUrlRequestModelCopyWith<$Res> {
  factory $PresignedUrlRequestModelCopyWith(PresignedUrlRequestModel value,
          $Res Function(PresignedUrlRequestModel) then) =
      _$PresignedUrlRequestModelCopyWithImpl<$Res, PresignedUrlRequestModel>;
  @useResult
  $Res call(
      {String fileName,
      int fileSize,
      String? contentType,
      AttachmentType attachmentType});
}

/// @nodoc
class _$PresignedUrlRequestModelCopyWithImpl<$Res,
        $Val extends PresignedUrlRequestModel>
    implements $PresignedUrlRequestModelCopyWith<$Res> {
  _$PresignedUrlRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresignedUrlRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileSize = null,
    Object? contentType = freezed,
    Object? attachmentType = null,
  }) {
    return _then(_value.copyWith(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresignedUrlRequestModelImplCopyWith<$Res>
    implements $PresignedUrlRequestModelCopyWith<$Res> {
  factory _$$PresignedUrlRequestModelImplCopyWith(
          _$PresignedUrlRequestModelImpl value,
          $Res Function(_$PresignedUrlRequestModelImpl) then) =
      __$$PresignedUrlRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fileName,
      int fileSize,
      String? contentType,
      AttachmentType attachmentType});
}

/// @nodoc
class __$$PresignedUrlRequestModelImplCopyWithImpl<$Res>
    extends _$PresignedUrlRequestModelCopyWithImpl<$Res,
        _$PresignedUrlRequestModelImpl>
    implements _$$PresignedUrlRequestModelImplCopyWith<$Res> {
  __$$PresignedUrlRequestModelImplCopyWithImpl(
      _$PresignedUrlRequestModelImpl _value,
      $Res Function(_$PresignedUrlRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresignedUrlRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? fileSize = null,
    Object? contentType = freezed,
    Object? attachmentType = null,
  }) {
    return _then(_$PresignedUrlRequestModelImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      contentType: freezed == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentType: null == attachmentType
          ? _value.attachmentType
          : attachmentType // ignore: cast_nullable_to_non_nullable
              as AttachmentType,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$PresignedUrlRequestModelImpl implements _PresignedUrlRequestModel {
  const _$PresignedUrlRequestModelImpl(
      {required this.fileName,
      required this.fileSize,
      this.contentType,
      required this.attachmentType});

  factory _$PresignedUrlRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresignedUrlRequestModelImplFromJson(json);

  @override
  final String fileName;
  @override
  final int fileSize;
// long на сервере, int в Dart
  @override
  final String? contentType;
  @override
  final AttachmentType attachmentType;

  @override
  String toString() {
    return 'PresignedUrlRequestModel(fileName: $fileName, fileSize: $fileSize, contentType: $contentType, attachmentType: $attachmentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresignedUrlRequestModelImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fileName, fileSize, contentType, attachmentType);

  /// Create a copy of PresignedUrlRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresignedUrlRequestModelImplCopyWith<_$PresignedUrlRequestModelImpl>
      get copyWith => __$$PresignedUrlRequestModelImplCopyWithImpl<
          _$PresignedUrlRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresignedUrlRequestModelImplToJson(
      this,
    );
  }
}

abstract class _PresignedUrlRequestModel implements PresignedUrlRequestModel {
  const factory _PresignedUrlRequestModel(
          {required final String fileName,
          required final int fileSize,
          final String? contentType,
          required final AttachmentType attachmentType}) =
      _$PresignedUrlRequestModelImpl;

  factory _PresignedUrlRequestModel.fromJson(Map<String, dynamic> json) =
      _$PresignedUrlRequestModelImpl.fromJson;

  @override
  String get fileName;
  @override
  int get fileSize; // long на сервере, int в Dart
  @override
  String? get contentType;
  @override
  AttachmentType get attachmentType;

  /// Create a copy of PresignedUrlRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresignedUrlRequestModelImplCopyWith<_$PresignedUrlRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
