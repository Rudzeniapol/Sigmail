   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:sigmail_client/data/models/user/user_simple_model.dart';
   import 'package:sigmail_client/data/models/attachment/attachment_model.dart';
   // import 'package:sigmail_flutter_app/data/models/message/message_reaction_model.dart'; // Если реакции детализированы

   part 'message_model.freezed.dart';
   part 'message_model.g.dart';

   enum MessageStatusModel { // Соответствует вашему MessageStatus enum
     @JsonValue('Sending')
     sending, // Локальный статус на клиенте
     @JsonValue('Sent')
     sent,
     @JsonValue('Delivered')
     delivered,
     @JsonValue('Read')
     read,
     @JsonValue('Edited')
     edited,
     @JsonValue('Failed')
     failed // Локальный статус на клиенте
     // Deleted - можно обрабатывать как отсутствие сообщения или спец. флаг
   }

   @freezed
   class MessageModel with _$MessageModel {
     const factory MessageModel({
       required String id, // MongoDB ObjectId как строка
       required String chatId,
       required String senderId,
       UserSimpleModel? sender, // Детали отправителя, если API их возвращает
       String? text,
       @Default([]) List<AttachmentModel> attachments,
       required DateTime timestamp,
       DateTime? editedAt,
       MessageStatusModel? status, // Статус сообщения
       String? forwardedFromMessageId,
       UserSimpleModel? forwardedFromUser, // Если API возвращает детали переславшего
       // List<MessageReactionModel> reactions, // Если есть реакции
       // bool isPinned,
       // String? replyToMessageId,
       // MessageModel? replyToMessage, // Если API возвращает детали сообщения, на которое ответили
     }) = _MessageModel;

     factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
   }