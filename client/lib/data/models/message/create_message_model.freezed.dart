// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateMessageModel _$CreateMessageModelFromJson(Map<String, dynamic> json) {
  return _CreateMessageModel.fromJson(json);
}

/// @nodoc
mixin _$CreateMessageModel {
  String get chatId => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  List<CreateAttachmentModel> get attachments =>
      throw _privateConstructorUsedError;

  /// Serializes this CreateMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateMessageModelCopyWith<CreateMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMessageModelCopyWith<$Res> {
  factory $CreateMessageModelCopyWith(
          CreateMessageModel value, $Res Function(CreateMessageModel) then) =
      _$CreateMessageModelCopyWithImpl<$Res, CreateMessageModel>;
  @useResult
  $Res call(
      {String chatId, String? text, List<CreateAttachmentModel> attachments});
}

/// @nodoc
class _$CreateMessageModelCopyWithImpl<$Res, $Val extends CreateMessageModel>
    implements $CreateMessageModelCopyWith<$Res> {
  _$CreateMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = null,
    Object? text = freezed,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<CreateAttachmentModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateMessageModelImplCopyWith<$Res>
    implements $CreateMessageModelCopyWith<$Res> {
  factory _$$CreateMessageModelImplCopyWith(_$CreateMessageModelImpl value,
          $Res Function(_$CreateMessageModelImpl) then) =
      __$$CreateMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String chatId, String? text, List<CreateAttachmentModel> attachments});
}

/// @nodoc
class __$$CreateMessageModelImplCopyWithImpl<$Res>
    extends _$CreateMessageModelCopyWithImpl<$Res, _$CreateMessageModelImpl>
    implements _$$CreateMessageModelImplCopyWith<$Res> {
  __$$CreateMessageModelImplCopyWithImpl(_$CreateMessageModelImpl _value,
      $Res Function(_$CreateMessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = null,
    Object? text = freezed,
    Object? attachments = null,
  }) {
    return _then(_$CreateMessageModelImpl(
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<CreateAttachmentModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateMessageModelImpl implements _CreateMessageModel {
  const _$CreateMessageModelImpl(
      {required this.chatId,
      this.text,
      final List<CreateAttachmentModel> attachments = const []})
      : _attachments = attachments;

  factory _$CreateMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateMessageModelImplFromJson(json);

  @override
  final String chatId;
  @override
  final String? text;
  final List<CreateAttachmentModel> _attachments;
  @override
  @JsonKey()
  List<CreateAttachmentModel> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'CreateMessageModel(chatId: $chatId, text: $text, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMessageModelImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chatId, text,
      const DeepCollectionEquality().hash(_attachments));

  /// Create a copy of CreateMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMessageModelImplCopyWith<_$CreateMessageModelImpl> get copyWith =>
      __$$CreateMessageModelImplCopyWithImpl<_$CreateMessageModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateMessageModelImplToJson(
      this,
    );
  }
}

abstract class _CreateMessageModel implements CreateMessageModel {
  const factory _CreateMessageModel(
          {required final String chatId,
          final String? text,
          final List<CreateAttachmentModel> attachments}) =
      _$CreateMessageModelImpl;

  factory _CreateMessageModel.fromJson(Map<String, dynamic> json) =
      _$CreateMessageModelImpl.fromJson;

  @override
  String get chatId;
  @override
  String? get text;
  @override
  List<CreateAttachmentModel> get attachments;

  /// Create a copy of CreateMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMessageModelImplCopyWith<_$CreateMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
