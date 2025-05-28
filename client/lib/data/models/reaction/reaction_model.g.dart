// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReactionModelImpl _$$ReactionModelImplFromJson(Map<String, dynamic> json) =>
    _$ReactionModelImpl(
      emoji: json['emoji'] as String,
      userIds: (json['userIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      firstReactedAt: json['firstReactedAt'] == null
          ? null
          : DateTime.parse(json['firstReactedAt'] as String),
      lastReactedAt: json['lastReactedAt'] == null
          ? null
          : DateTime.parse(json['lastReactedAt'] as String),
    );

Map<String, dynamic> _$$ReactionModelImplToJson(_$ReactionModelImpl instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'userIds': instance.userIds,
      'firstReactedAt': instance.firstReactedAt?.toIso8601String(),
      'lastReactedAt': instance.lastReactedAt?.toIso8601String(),
    };
