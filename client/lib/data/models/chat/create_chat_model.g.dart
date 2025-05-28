// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateChatModelImpl _$$CreateChatModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateChatModelImpl(
      name: json['name'] as String?,
      type: $enumDecode(_$ChatTypeModelEnumMap, json['type']),
      memberIds:
          (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$CreateChatModelImplToJson(
        _$CreateChatModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$ChatTypeModelEnumMap[instance.type]!,
      'memberIds': instance.memberIds,
      'description': instance.description,
    };

const _$ChatTypeModelEnumMap = {
  ChatTypeModel.private: 'Private',
  ChatTypeModel.group: 'Group',
  ChatTypeModel.channel: 'Channel',
};
