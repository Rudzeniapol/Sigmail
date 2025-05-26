      // lib/data/models/chat/create_chat_model.dart
      import 'package:freezed_annotation/freezed_annotation.dart';
      import 'package:sigmail_client/data/models/chat/chat_model.dart'; // Нужен для ChatTypeModel

      part 'create_chat_model.freezed.dart';
      part 'create_chat_model.g.dart';

      @freezed
      class CreateChatModel with _$CreateChatModel {
        const factory CreateChatModel({
          String? name, // Для Group/Channel. Для приватного может быть null, и сервер сгенерирует имя.
          required ChatTypeModel type, // Восстанавливаем тип чата
          required List<String> memberIds, // ID участников, кроме создателя
          String? description, // Если нужно в будущем
        }) = _CreateChatModel;

        factory CreateChatModel.fromJson(Map<String, dynamic> json) => _$CreateChatModelFromJson(json);
      }