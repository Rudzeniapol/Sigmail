// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileEvent {
  File get imageFile => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File imageFile) avatarUpdateRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File imageFile)? avatarUpdateRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File imageFile)? avatarUpdateRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AvatarUpdateRequested value)
        avatarUpdateRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AvatarUpdateRequested value)? avatarUpdateRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AvatarUpdateRequested value)? avatarUpdateRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileEventCopyWith<ProfileEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileEventCopyWith<$Res> {
  factory $ProfileEventCopyWith(
          ProfileEvent value, $Res Function(ProfileEvent) then) =
      _$ProfileEventCopyWithImpl<$Res, ProfileEvent>;
  @useResult
  $Res call({File imageFile});
}

/// @nodoc
class _$ProfileEventCopyWithImpl<$Res, $Val extends ProfileEvent>
    implements $ProfileEventCopyWith<$Res> {
  _$ProfileEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageFile = null,
  }) {
    return _then(_value.copyWith(
      imageFile: null == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AvatarUpdateRequestedImplCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory _$$AvatarUpdateRequestedImplCopyWith(
          _$AvatarUpdateRequestedImpl value,
          $Res Function(_$AvatarUpdateRequestedImpl) then) =
      __$$AvatarUpdateRequestedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({File imageFile});
}

/// @nodoc
class __$$AvatarUpdateRequestedImplCopyWithImpl<$Res>
    extends _$ProfileEventCopyWithImpl<$Res, _$AvatarUpdateRequestedImpl>
    implements _$$AvatarUpdateRequestedImplCopyWith<$Res> {
  __$$AvatarUpdateRequestedImplCopyWithImpl(_$AvatarUpdateRequestedImpl _value,
      $Res Function(_$AvatarUpdateRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageFile = null,
  }) {
    return _then(_$AvatarUpdateRequestedImpl(
      imageFile: null == imageFile
          ? _value.imageFile
          : imageFile // ignore: cast_nullable_to_non_nullable
              as File,
    ));
  }
}

/// @nodoc

class _$AvatarUpdateRequestedImpl implements AvatarUpdateRequested {
  const _$AvatarUpdateRequestedImpl({required this.imageFile});

  @override
  final File imageFile;

  @override
  String toString() {
    return 'ProfileEvent.avatarUpdateRequested(imageFile: $imageFile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvatarUpdateRequestedImpl &&
            (identical(other.imageFile, imageFile) ||
                other.imageFile == imageFile));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageFile);

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvatarUpdateRequestedImplCopyWith<_$AvatarUpdateRequestedImpl>
      get copyWith => __$$AvatarUpdateRequestedImplCopyWithImpl<
          _$AvatarUpdateRequestedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(File imageFile) avatarUpdateRequested,
  }) {
    return avatarUpdateRequested(imageFile);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(File imageFile)? avatarUpdateRequested,
  }) {
    return avatarUpdateRequested?.call(imageFile);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(File imageFile)? avatarUpdateRequested,
    required TResult orElse(),
  }) {
    if (avatarUpdateRequested != null) {
      return avatarUpdateRequested(imageFile);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AvatarUpdateRequested value)
        avatarUpdateRequested,
  }) {
    return avatarUpdateRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AvatarUpdateRequested value)? avatarUpdateRequested,
  }) {
    return avatarUpdateRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AvatarUpdateRequested value)? avatarUpdateRequested,
    required TResult orElse(),
  }) {
    if (avatarUpdateRequested != null) {
      return avatarUpdateRequested(this);
    }
    return orElse();
  }
}

abstract class AvatarUpdateRequested implements ProfileEvent {
  const factory AvatarUpdateRequested({required final File imageFile}) =
      _$AvatarUpdateRequestedImpl;

  @override
  File get imageFile;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvatarUpdateRequestedImplCopyWith<_$AvatarUpdateRequestedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProfileState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UserModel updatedUser) updateSuccess,
    required TResult Function(String error) updateFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UserModel updatedUser)? updateSuccess,
    TResult? Function(String error)? updateFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UserModel updatedUser)? updateSuccess,
    TResult Function(String error)? updateFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_UpdateSuccess value) updateSuccess,
    required TResult Function(_UpdateFailure value) updateFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_UpdateSuccess value)? updateSuccess,
    TResult? Function(_UpdateFailure value)? updateFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_UpdateSuccess value)? updateSuccess,
    TResult Function(_UpdateFailure value)? updateFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ProfileState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UserModel updatedUser) updateSuccess,
    required TResult Function(String error) updateFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UserModel updatedUser)? updateSuccess,
    TResult? Function(String error)? updateFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UserModel updatedUser)? updateSuccess,
    TResult Function(String error)? updateFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_UpdateSuccess value) updateSuccess,
    required TResult Function(_UpdateFailure value) updateFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_UpdateSuccess value)? updateSuccess,
    TResult? Function(_UpdateFailure value)? updateFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_UpdateSuccess value)? updateSuccess,
    TResult Function(_UpdateFailure value)? updateFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ProfileState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ProfileState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UserModel updatedUser) updateSuccess,
    required TResult Function(String error) updateFailure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UserModel updatedUser)? updateSuccess,
    TResult? Function(String error)? updateFailure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UserModel updatedUser)? updateSuccess,
    TResult Function(String error)? updateFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_UpdateSuccess value) updateSuccess,
    required TResult Function(_UpdateFailure value) updateFailure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_UpdateSuccess value)? updateSuccess,
    TResult? Function(_UpdateFailure value)? updateFailure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_UpdateSuccess value)? updateSuccess,
    TResult Function(_UpdateFailure value)? updateFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ProfileState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$UpdateSuccessImplCopyWith<$Res> {
  factory _$$UpdateSuccessImplCopyWith(
          _$UpdateSuccessImpl value, $Res Function(_$UpdateSuccessImpl) then) =
      __$$UpdateSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UserModel updatedUser});

  $UserModelCopyWith<$Res> get updatedUser;
}

/// @nodoc
class __$$UpdateSuccessImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UpdateSuccessImpl>
    implements _$$UpdateSuccessImplCopyWith<$Res> {
  __$$UpdateSuccessImplCopyWithImpl(
      _$UpdateSuccessImpl _value, $Res Function(_$UpdateSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updatedUser = null,
  }) {
    return _then(_$UpdateSuccessImpl(
      updatedUser: null == updatedUser
          ? _value.updatedUser
          : updatedUser // ignore: cast_nullable_to_non_nullable
              as UserModel,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get updatedUser {
    return $UserModelCopyWith<$Res>(_value.updatedUser, (value) {
      return _then(_value.copyWith(updatedUser: value));
    });
  }
}

/// @nodoc

class _$UpdateSuccessImpl implements _UpdateSuccess {
  const _$UpdateSuccessImpl({required this.updatedUser});

  @override
  final UserModel updatedUser;

  @override
  String toString() {
    return 'ProfileState.updateSuccess(updatedUser: $updatedUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateSuccessImpl &&
            (identical(other.updatedUser, updatedUser) ||
                other.updatedUser == updatedUser));
  }

  @override
  int get hashCode => Object.hash(runtimeType, updatedUser);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateSuccessImplCopyWith<_$UpdateSuccessImpl> get copyWith =>
      __$$UpdateSuccessImplCopyWithImpl<_$UpdateSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UserModel updatedUser) updateSuccess,
    required TResult Function(String error) updateFailure,
  }) {
    return updateSuccess(updatedUser);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UserModel updatedUser)? updateSuccess,
    TResult? Function(String error)? updateFailure,
  }) {
    return updateSuccess?.call(updatedUser);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UserModel updatedUser)? updateSuccess,
    TResult Function(String error)? updateFailure,
    required TResult orElse(),
  }) {
    if (updateSuccess != null) {
      return updateSuccess(updatedUser);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_UpdateSuccess value) updateSuccess,
    required TResult Function(_UpdateFailure value) updateFailure,
  }) {
    return updateSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_UpdateSuccess value)? updateSuccess,
    TResult? Function(_UpdateFailure value)? updateFailure,
  }) {
    return updateSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_UpdateSuccess value)? updateSuccess,
    TResult Function(_UpdateFailure value)? updateFailure,
    required TResult orElse(),
  }) {
    if (updateSuccess != null) {
      return updateSuccess(this);
    }
    return orElse();
  }
}

abstract class _UpdateSuccess implements ProfileState {
  const factory _UpdateSuccess({required final UserModel updatedUser}) =
      _$UpdateSuccessImpl;

  UserModel get updatedUser;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateSuccessImplCopyWith<_$UpdateSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateFailureImplCopyWith<$Res> {
  factory _$$UpdateFailureImplCopyWith(
          _$UpdateFailureImpl value, $Res Function(_$UpdateFailureImpl) then) =
      __$$UpdateFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$UpdateFailureImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UpdateFailureImpl>
    implements _$$UpdateFailureImplCopyWith<$Res> {
  __$$UpdateFailureImplCopyWithImpl(
      _$UpdateFailureImpl _value, $Res Function(_$UpdateFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$UpdateFailureImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UpdateFailureImpl implements _UpdateFailure {
  const _$UpdateFailureImpl({required this.error});

  @override
  final String error;

  @override
  String toString() {
    return 'ProfileState.updateFailure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateFailureImplCopyWith<_$UpdateFailureImpl> get copyWith =>
      __$$UpdateFailureImplCopyWithImpl<_$UpdateFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UserModel updatedUser) updateSuccess,
    required TResult Function(String error) updateFailure,
  }) {
    return updateFailure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UserModel updatedUser)? updateSuccess,
    TResult? Function(String error)? updateFailure,
  }) {
    return updateFailure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UserModel updatedUser)? updateSuccess,
    TResult Function(String error)? updateFailure,
    required TResult orElse(),
  }) {
    if (updateFailure != null) {
      return updateFailure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_UpdateSuccess value) updateSuccess,
    required TResult Function(_UpdateFailure value) updateFailure,
  }) {
    return updateFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_UpdateSuccess value)? updateSuccess,
    TResult? Function(_UpdateFailure value)? updateFailure,
  }) {
    return updateFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_UpdateSuccess value)? updateSuccess,
    TResult Function(_UpdateFailure value)? updateFailure,
    required TResult orElse(),
  }) {
    if (updateFailure != null) {
      return updateFailure(this);
    }
    return orElse();
  }
}

abstract class _UpdateFailure implements ProfileState {
  const factory _UpdateFailure({required final String error}) =
      _$UpdateFailureImpl;

  String get error;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateFailureImplCopyWith<_$UpdateFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
