// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      sender:
          json['sender'] == null
              ? null
              : UserSimpleModel.fromJson(
                json['sender'] as Map<String, dynamic>,
              ),
      text: json['text'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timestamp: DateTime.parse(json['timestamp'] as String),
      editedAt:
          json['editedAt'] == null
              ? null
              : DateTime.parse(json['editedAt'] as String),
      status: $enumDecodeNullable(_$MessageStatusModelEnumMap, json['status']),
      forwardedFromMessageId: json['forwardedFromMessageId'] as String?,
      forwardedFromUser:
          json['forwardedFromUser'] == null
              ? null
              : UserSimpleModel.fromJson(
                json['forwardedFromUser'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'sender': instance.sender,
      'text': instance.text,
      'attachments': instance.attachments,
      'timestamp': instance.timestamp.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'status': _$MessageStatusModelEnumMap[instance.status],
      'forwardedFromMessageId': instance.forwardedFromMessageId,
      'forwardedFromUser': instance.forwardedFromUser,
    };

const _$MessageStatusModelEnumMap = {
  MessageStatusModel.sending: 'Sending',
  MessageStatusModel.sent: 'Sent',
  MessageStatusModel.delivered: 'Delivered',
  MessageStatusModel.read: 'Read',
  MessageStatusModel.edited: 'Edited',
  MessageStatusModel.failed: 'Failed',
};
