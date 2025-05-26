import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
// Возможно, понадобится Result-тип для обработки ошибок, как в dartz
// import 'package:dartz/dartz.dart';
// import 'package:sigmail_client/core/error/failures.dart';

// Импорты для вложений
import 'package:cross_file/cross_file.dart'; 
import 'package:sigmail_client/data/models/attachment/presigned_url_request_model.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_response_model.dart';
import 'package:sigmail_client/data/models/attachment/create_message_with_attachment_client_dto.dart';

abstract class ChatRepository {
  // Получить список чатов пользователя (с пагинацией, если нужно)
  Future<Either<Failure, List<ChatModel>>> getChats({int pageNumber = 1, int pageSize = 20});

  // Получить конкретный чат по ID (если не загружен в списке или для обновления)
  Future<Either<Failure, ChatModel>> getChatById(String chatId);

  // Создать новый чат
  Future<Either<Failure, ChatModel>> createChat(CreateChatModel createChatModel);

  // Получить сообщения для конкретного чата (с пагинацией)
  Future<Either<Failure, List<MessageModel>>> getChatMessages(
    String chatId, {
    int pageNumber = 1, 
    int pageSize = 50
  });

  // Отправить сообщение
  Future<Either<Failure, MessageModel>> sendMessage(CreateMessageModel messageModel);
  
  // Наблюдение за новыми сообщениями в чате
  Stream<MessageModel> observeMessages(String chatId);

  // Наблюдение за обновлениями деталей чата (например, последнее сообщение, имя и т.д.)
  // Переименовываем с observeChatUpdates на observeChatDetails
  Stream<ChatModel> observeChatDetails(String chatId);

  // Отписаться от обновлений (если это не управляется автоматически при закрытии Stream)
  // Future<void> disposeChatObserver(String chatId); // Может и не понадобиться, если StreamController закрывается корректно

  // Методы для вложений
  Future<Either<Failure, PresignedUrlResponseModel>> getPresignedUploadUrl(PresignedUrlRequestModel request);
  Future<Either<Failure, void>> uploadFileToS3(String presignedUrl, XFile file, String? contentType);
  Future<Either<Failure, MessageModel>> sendMessageWithAttachment(CreateMessageWithAttachmentClientDto dto);

  // TODO: Добавить другие методы, если необходимо:
  // - Пометить сообщения как прочитанные
  // - Обновить настройки чата (имя, аватар)
  // - Добавить/удалить участников из чата
  // - Получить список участников чата
  // - Поиск чатов/сообщений
} 