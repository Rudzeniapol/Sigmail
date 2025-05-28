// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id =>
      throw _privateConstructorUsedError; // MongoDB ObjectId как строка
  String get chatId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  UserSimpleModel? get sender =>
      throw _privateConstructorUsedError; // Детали отправителя, если API их возвращает
  String? get text => throw _privateConstructorUsedError;
  List<AttachmentModel> get attachments => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  MessageStatusModel? get status =>
      throw _privateConstructorUsedError; // Статус сообщения
  String? get forwardedFromMessageId => throw _privateConstructorUsedError;
  UserSimpleModel? get forwardedFromUser =>
      throw _privateConstructorUsedError; // Если API возвращает детали переславшего
  List<ReactionModel> get reactions => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      String chatId,
      String senderId,
      UserSimpleModel? sender,
      String? text,
      List<AttachmentModel> attachments,
      DateTime timestamp,
      DateTime? editedAt,
      MessageStatusModel? status,
      String? forwardedFromMessageId,
      UserSimpleModel? forwardedFromUser,
      List<ReactionModel> reactions});

  $UserSimpleModelCopyWith<$Res>? get sender;
  $UserSimpleModelCopyWith<$Res>? get forwardedFromUser;
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? sender = freezed,
    Object? text = freezed,
    Object? attachments = null,
    Object? timestamp = null,
    Object? editedAt = freezed,
    Object? status = freezed,
    Object? forwardedFromMessageId = freezed,
    Object? forwardedFromUser = freezed,
    Object? reactions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as UserSimpleModel?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<AttachmentModel>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatusModel?,
      forwardedFromMessageId: freezed == forwardedFromMessageId
          ? _value.forwardedFromMessageId
          : forwardedFromMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromUser: freezed == forwardedFromUser
          ? _value.forwardedFromUser
          : forwardedFromUser // ignore: cast_nullable_to_non_nullable
              as UserSimpleModel?,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<ReactionModel>,
    ) as $Val);
  }

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSimpleModelCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $UserSimpleModelCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSimpleModelCopyWith<$Res>? get forwardedFromUser {
    if (_value.forwardedFromUser == null) {
      return null;
    }

    return $UserSimpleModelCopyWith<$Res>(_value.forwardedFromUser!, (value) {
      return _then(_value.copyWith(forwardedFromUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String chatId,
      String senderId,
      UserSimpleModel? sender,
      String? text,
      List<AttachmentModel> attachments,
      DateTime timestamp,
      DateTime? editedAt,
      MessageStatusModel? status,
      String? forwardedFromMessageId,
      UserSimpleModel? forwardedFromUser,
      List<ReactionModel> reactions});

  @override
  $UserSimpleModelCopyWith<$Res>? get sender;
  @override
  $UserSimpleModelCopyWith<$Res>? get forwardedFromUser;
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? sender = freezed,
    Object? text = freezed,
    Object? attachments = null,
    Object? timestamp = null,
    Object? editedAt = freezed,
    Object? status = freezed,
    Object? forwardedFromMessageId = freezed,
    Object? forwardedFromUser = freezed,
    Object? reactions = null,
  }) {
    return _then(_$MessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as UserSimpleModel?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<AttachmentModel>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatusModel?,
      forwardedFromMessageId: freezed == forwardedFromMessageId
          ? _value.forwardedFromMessageId
          : forwardedFromMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromUser: freezed == forwardedFromUser
          ? _value.forwardedFromUser
          : forwardedFromUser // ignore: cast_nullable_to_non_nullable
              as UserSimpleModel?,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<ReactionModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {required this.id,
      required this.chatId,
      required this.senderId,
      this.sender,
      this.text,
      final List<AttachmentModel> attachments = const [],
      required this.timestamp,
      this.editedAt,
      this.status,
      this.forwardedFromMessageId,
      this.forwardedFromUser,
      final List<ReactionModel> reactions = const []})
      : _attachments = attachments,
        _reactions = reactions;

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
// MongoDB ObjectId как строка
  @override
  final String chatId;
  @override
  final String senderId;
  @override
  final UserSimpleModel? sender;
// Детали отправителя, если API их возвращает
  @override
  final String? text;
  final List<AttachmentModel> _attachments;
  @override
  @JsonKey()
  List<AttachmentModel> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final DateTime timestamp;
  @override
  final DateTime? editedAt;
  @override
  final MessageStatusModel? status;
// Статус сообщения
  @override
  final String? forwardedFromMessageId;
  @override
  final UserSimpleModel? forwardedFromUser;
// Если API возвращает детали переславшего
  final List<ReactionModel> _reactions;
// Если API возвращает детали переславшего
  @override
  @JsonKey()
  List<ReactionModel> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, sender: $sender, text: $text, attachments: $attachments, timestamp: $timestamp, editedAt: $editedAt, status: $status, forwardedFromMessageId: $forwardedFromMessageId, forwardedFromUser: $forwardedFromUser, reactions: $reactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.forwardedFromMessageId, forwardedFromMessageId) ||
                other.forwardedFromMessageId == forwardedFromMessageId) &&
            (identical(other.forwardedFromUser, forwardedFromUser) ||
                other.forwardedFromUser == forwardedFromUser) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      chatId,
      senderId,
      sender,
      text,
      const DeepCollectionEquality().hash(_attachments),
      timestamp,
      editedAt,
      status,
      forwardedFromMessageId,
      forwardedFromUser,
      const DeepCollectionEquality().hash(_reactions));

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
      {required final String id,
      required final String chatId,
      required final String senderId,
      final UserSimpleModel? sender,
      final String? text,
      final List<AttachmentModel> attachments,
      required final DateTime timestamp,
      final DateTime? editedAt,
      final MessageStatusModel? status,
      final String? forwardedFromMessageId,
      final UserSimpleModel? forwardedFromUser,
      final List<ReactionModel> reactions}) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id; // MongoDB ObjectId как строка
  @override
  String get chatId;
  @override
  String get senderId;
  @override
  UserSimpleModel? get sender; // Детали отправителя, если API их возвращает
  @override
  String? get text;
  @override
  List<AttachmentModel> get attachments;
  @override
  DateTime get timestamp;
  @override
  DateTime? get editedAt;
  @override
  MessageStatusModel? get status; // Статус сообщения
  @override
  String? get forwardedFromMessageId;
  @override
  UserSimpleModel?
      get forwardedFromUser; // Если API возвращает детали переславшего
  @override
  List<ReactionModel> get reactions;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
