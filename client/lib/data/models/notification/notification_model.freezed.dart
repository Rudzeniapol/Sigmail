// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id =>
      throw _privateConstructorUsedError; // MongoDB ObjectId как строка
  String get userId => throw _privateConstructorUsedError; // Кому уведомление
  NotificationTypeModel get type => throw _privateConstructorUsedError;
  String? get title =>
      throw _privateConstructorUsedError; // Необязательный, если тип сам по себе информативен
  String get message => throw _privateConstructorUsedError; // Текст уведомления
  String? get relatedEntityId =>
      throw _privateConstructorUsedError; // ID связанной сущности (например, chatId, userId)
  String? get relatedEntityType =>
      throw _privateConstructorUsedError; // Тип связанной сущности ("Chat", "User")
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      NotificationTypeModel type,
      String? title,
      String message,
      String? relatedEntityId,
      String? relatedEntityType,
      bool isRead,
      DateTime createdAt});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = freezed,
    Object? message = null,
    Object? relatedEntityId = freezed,
    Object? relatedEntityType = freezed,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationTypeModel,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      relatedEntityId: freezed == relatedEntityId
          ? _value.relatedEntityId
          : relatedEntityId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedEntityType: freezed == relatedEntityType
          ? _value.relatedEntityType
          : relatedEntityType // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      NotificationTypeModel type,
      String? title,
      String message,
      String? relatedEntityId,
      String? relatedEntityType,
      bool isRead,
      DateTime createdAt});
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? title = freezed,
    Object? message = null,
    Object? relatedEntityId = freezed,
    Object? relatedEntityType = freezed,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(_$NotificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationTypeModel,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      relatedEntityId: freezed == relatedEntityId
          ? _value.relatedEntityId
          : relatedEntityId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedEntityType: freezed == relatedEntityType
          ? _value.relatedEntityType
          : relatedEntityType // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl(
      {required this.id,
      required this.userId,
      required this.type,
      this.title,
      required this.message,
      this.relatedEntityId,
      this.relatedEntityType,
      required this.isRead,
      required this.createdAt});

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
// MongoDB ObjectId как строка
  @override
  final String userId;
// Кому уведомление
  @override
  final NotificationTypeModel type;
  @override
  final String? title;
// Необязательный, если тип сам по себе информативен
  @override
  final String message;
// Текст уведомления
  @override
  final String? relatedEntityId;
// ID связанной сущности (например, chatId, userId)
  @override
  final String? relatedEntityType;
// Тип связанной сущности ("Chat", "User")
  @override
  final bool isRead;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, type: $type, title: $title, message: $message, relatedEntityId: $relatedEntityId, relatedEntityType: $relatedEntityType, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.relatedEntityId, relatedEntityId) ||
                other.relatedEntityId == relatedEntityId) &&
            (identical(other.relatedEntityType, relatedEntityType) ||
                other.relatedEntityType == relatedEntityType) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, type, title, message,
      relatedEntityId, relatedEntityType, isRead, createdAt);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel(
      {required final String id,
      required final String userId,
      required final NotificationTypeModel type,
      final String? title,
      required final String message,
      final String? relatedEntityId,
      final String? relatedEntityType,
      required final bool isRead,
      required final DateTime createdAt}) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id; // MongoDB ObjectId как строка
  @override
  String get userId; // Кому уведомление
  @override
  NotificationTypeModel get type;
  @override
  String? get title; // Необязательный, если тип сам по себе информативен
  @override
  String get message; // Текст уведомления
  @override
  String?
      get relatedEntityId; // ID связанной сущности (например, chatId, userId)
  @override
  String? get relatedEntityType; // Тип связанной сущности ("Chat", "User")
  @override
  bool get isRead;
  @override
  DateTime get createdAt;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
