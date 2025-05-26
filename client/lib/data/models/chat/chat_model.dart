   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:sigmail_client/data/models/user/user_simple_model.dart'; // Упрощенная модель пользователя
   import 'package:sigmail_client/data/models/message/message_model.dart';   // Модель сообщения

   part 'chat_model.freezed.dart';
   part 'chat_model.g.dart';

   enum ChatTypeModel { // Соответствует вашему ChatType enum
     @JsonValue('Private') // Важно для правильной сериализации, если строки на бэке отличаются
     private,
     @JsonValue('Group')
     group,
     @JsonValue('Channel')
     channel
   }

   @freezed
   class ChatModel with _$ChatModel {
     const factory ChatModel({
       required String id,
       String? name, // Для групповых чатов и каналов
       required ChatTypeModel type,
       String? description,
       String? avatarUrl,
       required String creatorId, // Или UserSimpleModel creator, если API возвращает объект
       required DateTime createdAt,
       DateTime? updatedAt,
       MessageModel? lastMessage, // Последнее сообщение в чате
       @Default(0) int unreadCount,
       List<UserSimpleModel>? members, // Добавляем список участников
       int? memberCount, // Добавляем количество участников
       // Map<String, dynamic>? metadata, // Для дополнительных кастомных данных, если есть
     }) = _ChatModel;

     factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
   }