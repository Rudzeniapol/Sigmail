   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'notification_model.freezed.dart';
   part 'notification_model.g.dart';

   enum NotificationTypeModel { // Соответствует вашему NotificationType enum
     // Перечислите здесь ваши типы уведомлений, например:
     @JsonValue('NewMessage')
     newMessage,
     @JsonValue('ContactRequestReceived')
     contactRequestReceived,
     @JsonValue('ContactRequestAccepted')
     contactRequestAccepted,
     // ... другие типы
   }

   @freezed
   class NotificationModel with _$NotificationModel {
     const factory NotificationModel({
       required String id, // MongoDB ObjectId как строка
       required String userId, // Кому уведомление
       required NotificationTypeModel type,
       String? title, // Необязательный, если тип сам по себе информативен
       required String message, // Текст уведомления
       String? relatedEntityId, // ID связанной сущности (например, chatId, userId)
       String? relatedEntityType, // Тип связанной сущности ("Chat", "User")
       required bool isRead,
       required DateTime createdAt,
     }) = _NotificationModel;

     factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
   }