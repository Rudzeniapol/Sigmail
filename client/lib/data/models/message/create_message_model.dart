      // lib/data/models/message/create_message_model.dart
      import 'package:freezed_annotation/freezed_annotation.dart';
      import 'package:sigmail_client/data/models/attachment/create_attachment_model.dart'; // Модель для создания вложения

      part 'create_message_model.freezed.dart';
      part 'create_message_model.g.dart';

      @freezed
      class CreateMessageModel with _$CreateMessageModel {
        const factory CreateMessageModel({
          required String chatId,
          String? text,
          @Default([]) List<CreateAttachmentModel> attachments,
          // String? replyToMessageId,
          // String? forwardedFromMessageId, // Если клиент может инициировать пересылку
        }) = _CreateMessageModel;

        factory CreateMessageModel.fromJson(Map<String, dynamic> json) => _$CreateMessageModelFromJson(json);
      }