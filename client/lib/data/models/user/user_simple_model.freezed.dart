// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_simple_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserSimpleModel _$UserSimpleModelFromJson(Map<String, dynamic> json) {
  return _UserSimpleModel.fromJson(json);
}

/// @nodoc
mixin _$UserSimpleModel {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this UserSimpleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSimpleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSimpleModelCopyWith<UserSimpleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSimpleModelCopyWith<$Res> {
  factory $UserSimpleModelCopyWith(
          UserSimpleModel value, $Res Function(UserSimpleModel) then) =
      _$UserSimpleModelCopyWithImpl<$Res, UserSimpleModel>;
  @useResult
  $Res call({String id, String username, String? profileImageUrl});
}

/// @nodoc
class _$UserSimpleModelCopyWithImpl<$Res, $Val extends UserSimpleModel>
    implements $UserSimpleModelCopyWith<$Res> {
  _$UserSimpleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSimpleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserSimpleModelImplCopyWith<$Res>
    implements $UserSimpleModelCopyWith<$Res> {
  factory _$$UserSimpleModelImplCopyWith(_$UserSimpleModelImpl value,
          $Res Function(_$UserSimpleModelImpl) then) =
      __$$UserSimpleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String username, String? profileImageUrl});
}

/// @nodoc
class __$$UserSimpleModelImplCopyWithImpl<$Res>
    extends _$UserSimpleModelCopyWithImpl<$Res, _$UserSimpleModelImpl>
    implements _$$UserSimpleModelImplCopyWith<$Res> {
  __$$UserSimpleModelImplCopyWithImpl(
      _$UserSimpleModelImpl _value, $Res Function(_$UserSimpleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserSimpleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(_$UserSimpleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSimpleModelImpl implements _UserSimpleModel {
  const _$UserSimpleModelImpl(
      {required this.id, required this.username, this.profileImageUrl});

  factory _$UserSimpleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSimpleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'UserSimpleModel(id: $id, username: $username, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSimpleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, profileImageUrl);

  /// Create a copy of UserSimpleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSimpleModelImplCopyWith<_$UserSimpleModelImpl> get copyWith =>
      __$$UserSimpleModelImplCopyWithImpl<_$UserSimpleModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSimpleModelImplToJson(
      this,
    );
  }
}

abstract class _UserSimpleModel implements UserSimpleModel {
  const factory _UserSimpleModel(
      {required final String id,
      required final String username,
      final String? profileImageUrl}) = _$UserSimpleModelImpl;

  factory _UserSimpleModel.fromJson(Map<String, dynamic> json) =
      _$UserSimpleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get profileImageUrl;

  /// Create a copy of UserSimpleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSimpleModelImplCopyWith<_$UserSimpleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
