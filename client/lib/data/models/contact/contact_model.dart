   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:sigmail_client/data/models/user/user_model.dart'; // Полная модель пользователя для контакта

   part 'contact_model.freezed.dart';
   part 'contact_model.g.dart';

   enum ContactStatusModel { // Соответствует вашему ContactRequestStatus enum
     @JsonValue('Pending')
     pending,
     @JsonValue('Accepted')
     accepted,
     @JsonValue('Declined')
     declined,
     @JsonValue('Blocked')
     blocked
   }

   @freezed
   class ContactModel with _$ContactModel {
     const factory ContactModel({
       required String contactEntryId, // ID записи Contact
       required UserModel user,         // Информация о пользователе-контакте
       required ContactStatusModel status,
       DateTime? requestedAt,
       DateTime? respondedAt,
       // bool amIInitiator, // Если нужно знать, кто отправил запрос
     }) = _ContactModel;

     factory ContactModel.fromJson(Map<String, dynamic> json) => _$ContactModelFromJson(json);
   }