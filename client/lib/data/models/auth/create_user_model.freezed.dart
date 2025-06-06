// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateUserModel _$CreateUserModelFromJson(Map<String, dynamic> json) {
  return _CreateUserModel.fromJson(json);
}

/// @nodoc
mixin _$CreateUserModel {
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this CreateUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateUserModelCopyWith<CreateUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateUserModelCopyWith<$Res> {
  factory $CreateUserModelCopyWith(
          CreateUserModel value, $Res Function(CreateUserModel) then) =
      _$CreateUserModelCopyWithImpl<$Res, CreateUserModel>;
  @useResult
  $Res call({String username, String email, String password});
}

/// @nodoc
class _$CreateUserModelCopyWithImpl<$Res, $Val extends CreateUserModel>
    implements $CreateUserModelCopyWith<$Res> {
  _$CreateUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateUserModelImplCopyWith<$Res>
    implements $CreateUserModelCopyWith<$Res> {
  factory _$$CreateUserModelImplCopyWith(_$CreateUserModelImpl value,
          $Res Function(_$CreateUserModelImpl) then) =
      __$$CreateUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String email, String password});
}

/// @nodoc
class __$$CreateUserModelImplCopyWithImpl<$Res>
    extends _$CreateUserModelCopyWithImpl<$Res, _$CreateUserModelImpl>
    implements _$$CreateUserModelImplCopyWith<$Res> {
  __$$CreateUserModelImplCopyWithImpl(
      _$CreateUserModelImpl _value, $Res Function(_$CreateUserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$CreateUserModelImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateUserModelImpl implements _CreateUserModel {
  const _$CreateUserModelImpl(
      {required this.username, required this.email, required this.password});

  factory _$CreateUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateUserModelImplFromJson(json);

  @override
  final String username;
  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'CreateUserModel(username: $username, email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateUserModelImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, email, password);

  /// Create a copy of CreateUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateUserModelImplCopyWith<_$CreateUserModelImpl> get copyWith =>
      __$$CreateUserModelImplCopyWithImpl<_$CreateUserModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateUserModelImplToJson(
      this,
    );
  }
}

abstract class _CreateUserModel implements CreateUserModel {
  const factory _CreateUserModel(
      {required final String username,
      required final String email,
      required final String password}) = _$CreateUserModelImpl;

  factory _CreateUserModel.fromJson(Map<String, dynamic> json) =
      _$CreateUserModelImpl.fromJson;

  @override
  String get username;
  @override
  String get email;
  @override
  String get password;

  /// Create a copy of CreateUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateUserModelImplCopyWith<_$CreateUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
