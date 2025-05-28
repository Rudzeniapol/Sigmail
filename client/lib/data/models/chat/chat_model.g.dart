// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatModelImpl _$$ChatModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatModelImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      type: $enumDecode(_$ChatTypeModelEnumMap, json['type']),
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastMessage: json['lastMessage'] == null
          ? null
          : MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => UserSimpleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      memberCount: (json['memberCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ChatModelImplToJson(_$ChatModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ChatTypeModelEnumMap[instance.type]!,
      'description': instance.description,
      'avatarUrl': instance.avatarUrl,
      'creatorId': instance.creatorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'members': instance.members,
      'memberCount': instance.memberCount,
    };

const _$ChatTypeModelEnumMap = {
  ChatTypeModel.private: 'Private',
  ChatTypeModel.group: 'Group',
  ChatTypeModel.channel: 'Channel',
};
