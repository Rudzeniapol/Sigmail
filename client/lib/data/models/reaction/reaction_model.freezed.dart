// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReactionModel _$ReactionModelFromJson(Map<String, dynamic> json) {
  return _ReactionModel.fromJson(json);
}

/// @nodoc
mixin _$ReactionModel {
  String get emoji => throw _privateConstructorUsedError;
  List<String> get userIds => throw _privateConstructorUsedError;
  DateTime? get firstReactedAt => throw _privateConstructorUsedError;
  DateTime? get lastReactedAt => throw _privateConstructorUsedError;

  /// Serializes this ReactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReactionModelCopyWith<ReactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionModelCopyWith<$Res> {
  factory $ReactionModelCopyWith(
          ReactionModel value, $Res Function(ReactionModel) then) =
      _$ReactionModelCopyWithImpl<$Res, ReactionModel>;
  @useResult
  $Res call(
      {String emoji,
      List<String> userIds,
      DateTime? firstReactedAt,
      DateTime? lastReactedAt});
}

/// @nodoc
class _$ReactionModelCopyWithImpl<$Res, $Val extends ReactionModel>
    implements $ReactionModelCopyWith<$Res> {
  _$ReactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? userIds = null,
    Object? firstReactedAt = freezed,
    Object? lastReactedAt = freezed,
  }) {
    return _then(_value.copyWith(
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      userIds: null == userIds
          ? _value.userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstReactedAt: freezed == firstReactedAt
          ? _value.firstReactedAt
          : firstReactedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReactedAt: freezed == lastReactedAt
          ? _value.lastReactedAt
          : lastReactedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReactionModelImplCopyWith<$Res>
    implements $ReactionModelCopyWith<$Res> {
  factory _$$ReactionModelImplCopyWith(
          _$ReactionModelImpl value, $Res Function(_$ReactionModelImpl) then) =
      __$$ReactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String emoji,
      List<String> userIds,
      DateTime? firstReactedAt,
      DateTime? lastReactedAt});
}

/// @nodoc
class __$$ReactionModelImplCopyWithImpl<$Res>
    extends _$ReactionModelCopyWithImpl<$Res, _$ReactionModelImpl>
    implements _$$ReactionModelImplCopyWith<$Res> {
  __$$ReactionModelImplCopyWithImpl(
      _$ReactionModelImpl _value, $Res Function(_$ReactionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? userIds = null,
    Object? firstReactedAt = freezed,
    Object? lastReactedAt = freezed,
  }) {
    return _then(_$ReactionModelImpl(
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      userIds: null == userIds
          ? _value._userIds
          : userIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstReactedAt: freezed == firstReactedAt
          ? _value.firstReactedAt
          : firstReactedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReactedAt: freezed == lastReactedAt
          ? _value.lastReactedAt
          : lastReactedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReactionModelImpl implements _ReactionModel {
  const _$ReactionModelImpl(
      {required this.emoji,
      final List<String> userIds = const [],
      this.firstReactedAt,
      this.lastReactedAt})
      : _userIds = userIds;

  factory _$ReactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReactionModelImplFromJson(json);

  @override
  final String emoji;
  final List<String> _userIds;
  @override
  @JsonKey()
  List<String> get userIds {
    if (_userIds is EqualUnmodifiableListView) return _userIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userIds);
  }

  @override
  final DateTime? firstReactedAt;
  @override
  final DateTime? lastReactedAt;

  @override
  String toString() {
    return 'ReactionModel(emoji: $emoji, userIds: $userIds, firstReactedAt: $firstReactedAt, lastReactedAt: $lastReactedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionModelImpl &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(other._userIds, _userIds) &&
            (identical(other.firstReactedAt, firstReactedAt) ||
                other.firstReactedAt == firstReactedAt) &&
            (identical(other.lastReactedAt, lastReactedAt) ||
                other.lastReactedAt == lastReactedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      emoji,
      const DeepCollectionEquality().hash(_userIds),
      firstReactedAt,
      lastReactedAt);

  /// Create a copy of ReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionModelImplCopyWith<_$ReactionModelImpl> get copyWith =>
      __$$ReactionModelImplCopyWithImpl<_$ReactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReactionModelImplToJson(
      this,
    );
  }
}

abstract class _ReactionModel implements ReactionModel {
  const factory _ReactionModel(
      {required final String emoji,
      final List<String> userIds,
      final DateTime? firstReactedAt,
      final DateTime? lastReactedAt}) = _$ReactionModelImpl;

  factory _ReactionModel.fromJson(Map<String, dynamic> json) =
      _$ReactionModelImpl.fromJson;

  @override
  String get emoji;
  @override
  List<String> get userIds;
  @override
  DateTime? get firstReactedAt;
  @override
  DateTime? get lastReactedAt;

  /// Create a copy of ReactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReactionModelImplCopyWith<_$ReactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
