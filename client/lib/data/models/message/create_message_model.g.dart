// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateMessageModelImpl _$$CreateMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateMessageModelImpl(
      chatId: json['chatId'] as String,
      text: json['text'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) =>
                  CreateAttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CreateMessageModelImplToJson(
        _$CreateMessageModelImpl instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'text': instance.text,
      'attachments': instance.attachments,
    };
