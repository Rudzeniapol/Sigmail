// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateChatModel _$CreateChatModelFromJson(Map<String, dynamic> json) {
  return _CreateChatModel.fromJson(json);
}

/// @nodoc
mixin _$CreateChatModel {
  String? get name =>
      throw _privateConstructorUsedError; // Для Group/Channel. Для приватного может быть null, и сервер сгенерирует имя.
  ChatTypeModel get type =>
      throw _privateConstructorUsedError; // Восстанавливаем тип чата
  List<String> get memberIds =>
      throw _privateConstructorUsedError; // ID участников, кроме создателя
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this CreateChatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateChatModelCopyWith<CreateChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateChatModelCopyWith<$Res> {
  factory $CreateChatModelCopyWith(
          CreateChatModel value, $Res Function(CreateChatModel) then) =
      _$CreateChatModelCopyWithImpl<$Res, CreateChatModel>;
  @useResult
  $Res call(
      {String? name,
      ChatTypeModel type,
      List<String> memberIds,
      String? description});
}

/// @nodoc
class _$CreateChatModelCopyWithImpl<$Res, $Val extends CreateChatModel>
    implements $CreateChatModelCopyWith<$Res> {
  _$CreateChatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? type = null,
    Object? memberIds = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatTypeModel,
      memberIds: null == memberIds
          ? _value.memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateChatModelImplCopyWith<$Res>
    implements $CreateChatModelCopyWith<$Res> {
  factory _$$CreateChatModelImplCopyWith(_$CreateChatModelImpl value,
          $Res Function(_$CreateChatModelImpl) then) =
      __$$CreateChatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      ChatTypeModel type,
      List<String> memberIds,
      String? description});
}

/// @nodoc
class __$$CreateChatModelImplCopyWithImpl<$Res>
    extends _$CreateChatModelCopyWithImpl<$Res, _$CreateChatModelImpl>
    implements _$$CreateChatModelImplCopyWith<$Res> {
  __$$CreateChatModelImplCopyWithImpl(
      _$CreateChatModelImpl _value, $Res Function(_$CreateChatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? type = null,
    Object? memberIds = null,
    Object? description = freezed,
  }) {
    return _then(_$CreateChatModelImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ChatTypeModel,
      memberIds: null == memberIds
          ? _value._memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateChatModelImpl implements _CreateChatModel {
  const _$CreateChatModelImpl(
      {this.name,
      required this.type,
      required final List<String> memberIds,
      this.description})
      : _memberIds = memberIds;

  factory _$CreateChatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateChatModelImplFromJson(json);

  @override
  final String? name;
// Для Group/Channel. Для приватного может быть null, и сервер сгенерирует имя.
  @override
  final ChatTypeModel type;
// Восстанавливаем тип чата
  final List<String> _memberIds;
// Восстанавливаем тип чата
  @override
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

// ID участников, кроме создателя
  @override
  final String? description;

  @override
  String toString() {
    return 'CreateChatModel(name: $name, type: $type, memberIds: $memberIds, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateChatModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._memberIds, _memberIds) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type,
      const DeepCollectionEquality().hash(_memberIds), description);

  /// Create a copy of CreateChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateChatModelImplCopyWith<_$CreateChatModelImpl> get copyWith =>
      __$$CreateChatModelImplCopyWithImpl<_$CreateChatModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateChatModelImplToJson(
      this,
    );
  }
}

abstract class _CreateChatModel implements CreateChatModel {
  const factory _CreateChatModel(
      {final String? name,
      required final ChatTypeModel type,
      required final List<String> memberIds,
      final String? description}) = _$CreateChatModelImpl;

  factory _CreateChatModel.fromJson(Map<String, dynamic> json) =
      _$CreateChatModelImpl.fromJson;

  @override
  String?
      get name; // Для Group/Channel. Для приватного может быть null, и сервер сгенерирует имя.
  @override
  ChatTypeModel get type; // Восстанавливаем тип чата
  @override
  List<String> get memberIds; // ID участников, кроме создателя
  @override
  String? get description;

  /// Create a copy of CreateChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateChatModelImplCopyWith<_$CreateChatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
