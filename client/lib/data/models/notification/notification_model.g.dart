// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeModelEnumMap, json['type']),
      title: json['title'] as String?,
      message: json['message'] as String,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'relatedEntityId': instance.relatedEntityId,
      'relatedEntityType': instance.relatedEntityType,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeModelEnumMap = {
  NotificationTypeModel.newMessage: 'NewMessage',
  NotificationTypeModel.contactRequestReceived: 'ContactRequestReceived',
  NotificationTypeModel.contactRequestAccepted: 'ContactRequestAccepted',
};
