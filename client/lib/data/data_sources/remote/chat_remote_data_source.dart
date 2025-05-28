import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart'; // XFile уже импортируется через cross_file
import 'package:cross_file/cross_file.dart';

import 'package:sigmail_client/core/constants.dart';
// import 'package:sigmail_client/core/error/exceptions.dart'; // УДАЛЯЕМ ЭТОТ ИМПОРТ
import 'package:sigmail_client/core/exceptions.dart';
// import 'package:sigmail_client/data/data_sources/remote/auth_remote_data_source.dart'; // Старый импорт ServerException - УДАЛЯЕМ или комментируем
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/reaction/reaction_model.dart';

// Импорты для вложений
import 'package:sigmail_client/data/models/attachment/presigned_url_request_model.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_response_model.dart';
import 'package:sigmail_client/data/models/attachment/create_message_with_attachment_client_dto.dart';

// Базовый URL уже должен быть в Dio, но эндпоинты здесь
// const String _chatsBaseUrlPath = '/chats'; // Для POST /api/chats, GET /api/chats/{id} и т.д.
// const String _messagesBaseUrlPath = '/messages'; // /api/messages
// const String _attachmentsBaseUrlPath = '/attachments'; // URL для вложений
// const String _userChatsUrl = '/users/me/chats'; // Старый неверный эндпоинт
// const String _myChatsUrlPath = '/chats/my'; // GET /api/chats/my - эндпоинт для получения чатов текущего пользователя

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getChats({int pageNumber = 1, int pageSize = 20});
  Future<ChatModel> getChatById(String chatId);
  Future<ChatModel> createChat(CreateChatModel createChatModel);
  Future<List<MessageModel>> getChatMessages(String chatId, {int pageNumber = 1, int pageSize = 50});
  Future<MessageModel> sendMessage(CreateMessageModel messageModel);

  // Новые методы для вложений
  Future<PresignedUrlResponseModel> getPresignedUploadUrl(PresignedUrlRequestModel request);
  Future<void> uploadFileToS3(String presignedUrl, XFile file, String? contentType);
  Future<MessageModel> sendMessageWithAttachment(CreateMessageWithAttachmentClientDto dto);

  // Методы для реакций
  Future<List<ReactionModel>> addReaction(String messageId, String emoji);
  Future<List<ReactionModel>> removeReaction(String messageId, String emoji);

  // Метод для пометки сообщений как прочитанных
  Future<void> markMessagesAsRead(String chatId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  static const String _chatsPath = '/Chats'; 
  static const String _messagesPath = '/Messages';
  static const String _attachmentsPath = '/attachments';
  static const String _myChatsPath = '/chats/my'; // Путь для "моих чатов"

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ChatModel>> getChats({int pageNumber = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        '$serverBaseUrl$_myChatsPath', // Исправлено
        queryParameters: {'page': pageNumber, 'pageSize': pageSize},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> chatListJson = response.data as List<dynamic>;
        return chatListJson.map((json) => ChatModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to get chats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during getChats');
    } catch (e) {
      throw ServerException('Unknown error during getChats: ${e.toString()}');
    }
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    try {
      final response = await _dio.get('$serverBaseUrl$_chatsPath/$chatId'); // Исправлено
      if (response.statusCode == 200 && response.data != null) {
        return ChatModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get chat by ID: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during getChatById');
    } catch (e) {
      throw ServerException('Unknown error during getChatById: ${e.toString()}');
    }
  }

  @override
  Future<ChatModel> createChat(CreateChatModel createChatModel) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_chatsPath', // Исправлено
        data: createChatModel.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) { 
        return ChatModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to create chat: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during createChat');
    } catch (e) {
      throw ServerException('Unknown error during createChat: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageModel>> getChatMessages(String chatId, {int pageNumber = 1, int pageSize = 50}) async {
    try {
      final response = await _dio.get(
        '$serverBaseUrl$_messagesPath/chat/$chatId', // Исправлено
        queryParameters: {
          'page': pageNumber, 
          'pageSize': pageSize,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => MessageModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw ServerException('Failed to load messages: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] as String? ?? e.message ?? 'Network error. Status: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerException('Unknown error while loading messages: ${e.toString()}');
    }
  }

  @override
  Future<MessageModel> sendMessage(CreateMessageModel messageModel) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_messagesPath', // Исправлено
        data: messageModel.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) { 
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to send message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during sendMessage. Status: ${e.response?.statusCode}');
    } catch (e) {
      throw ServerException('Unknown error during sendMessage: ${e.toString()}');
    }
  }

  // Реализация новых методов
  @override
  Future<PresignedUrlResponseModel> getPresignedUploadUrl(PresignedUrlRequestModel request) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_attachmentsPath/upload-url',
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return PresignedUrlResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get presigned URL: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during getPresignedUploadUrl. Status: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerException('Unknown error during getPresignedUploadUrl: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadFileToS3(String presignedUrl, XFile file, String? contentType) async {
    try {
      String effectiveUrl = presignedUrl;

      // Определяем, какой хост и схема должны быть для MinIO
      const String targetMinioHostPort = '10.0.2.2:9000';
      const String targetMinioScheme = 'http';

      // Разбираем полученный URL на компоненты
      Uri parsedSdkUrl = Uri.parse(presignedUrl);

      // Собираем новый URL с целевой схемой и хостом/портом,
      // но сохраняем путь и параметры запроса из оригинального URL
      effectiveUrl = Uri(
        scheme: targetMinioScheme, // Всегда используем http для MinIO в данном случае
        host: targetMinioHostPort.split(':')[0], // 10.0.2.2
        port: int.parse(targetMinioHostPort.split(':')[1]), // 9000
        path: parsedSdkUrl.path,
        query: parsedSdkUrl.query, // Важно сохранить все оригинальные query параметры, включая подпись!
      ).toString();

      if (kDebugMode) {
           print('[ChatRemoteDataSource] Original presigned URL from server: $presignedUrl');
           print('[ChatRemoteDataSource] Effective presigned URL for S3 upload: $effectiveUrl');
      }

      final dio = Dio(); 
      final stream = file.openRead();
      final length = await file.length();

      final response = await dio.put(
        effectiveUrl,
        data: stream,
        options: Options(
          headers: {
            Headers.contentLengthHeader: length,
            if (contentType != null) Headers.contentTypeHeader: contentType,
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'S3 Upload Error: Status code ${response.statusCode}';
        if (response.data != null) {
          if (response.data is String) {
            errorMessage += ' - ${response.data}';
          } else if (response.data is Map) {
            errorMessage += ' - ${jsonEncode(response.data)}';
          } else {
            try {
              // Попытка декодирования, если это байты (например, XML ошибка от S3)
              final responseBody = utf8.decode(response.data as List<int>, allowMalformed: true);
              errorMessage += ' - $responseBody';
            } catch (_) {
              errorMessage += ' - (Could not decode response body)';
            }
          }
        }
        throw ServerException(errorMessage);
      }
       if (kDebugMode) {
        print('[ChatRemoteDataSource] File uploaded successfully to S3. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw ServerException(
        e.response?.data?.toString() ?? e.message ?? 'Dio error during S3 upload. Status: ${e.response?.statusCode}',
      );
    } catch (e) {
      throw ServerException('Unexpected error during S3 upload: ${e.toString()}');
    }
  }

  @override
  Future<MessageModel> sendMessageWithAttachment(CreateMessageWithAttachmentClientDto dto) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_messagesPath/with-attachment',
        data: dto.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to send message with attachment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error: sendMessageWithAttachment. Status: ${e.response?.statusCode}');
    } catch (e) {
      throw ServerException('Unknown error during sendMessageWithAttachment: ${e.toString()}');
    }
  }

  // Методы для реакций
  @override
  Future<List<ReactionModel>> addReaction(String messageId, String emoji) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_messagesPath/$messageId/reactions',
        data: {'emoji': emoji},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => ReactionModel.fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException('Message not found when adding reaction. Status: ${response.statusCode}');
      } 
      else {
        throw ServerException('Failed to add reaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(e.response?.data?['message']?.toString() ?? e.message ?? 'Message not found (Dio). Status: ${e.response?.statusCode}');
      }
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during addReaction. Status: ${e.response?.statusCode}');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Unknown error during addReaction: ${e.toString()}');
    }
  }

  @override
  Future<List<ReactionModel>> removeReaction(String messageId, String emoji) async {
    try {
      final response = await _dio.delete(
        '$serverBaseUrl$_messagesPath/$messageId/reactions',
        data: {'emoji': emoji}, // Emoji передается в теле запроса
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => ReactionModel.fromJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 404) {
         throw NotFoundException('Message or reaction not found when removing reaction. Status: ${response.statusCode}');
      }
      else {
        throw ServerException('Failed to remove reaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(e.response?.data?['message']?.toString() ?? e.message ?? 'Message or reaction not found (Dio). Status: ${e.response?.statusCode}');
      }
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during removeReaction. Status: ${e.response?.statusCode}');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Unknown error during removeReaction: ${e.toString()}');
    }
  }

  // Метод для пометки сообщений как прочитанных
  @override
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final response = await _dio.post(
        '$serverBaseUrl$_chatsPath/$chatId/read',
      );
      // Ожидаем успешный статус, например 204 No Content или 200 OK
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to mark messages as read: ${response.statusCode}');
      }
      // Для void методов обычно ничего не возвращаем
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during markMessagesAsRead. Status: ${e.response?.statusCode}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unknown error during markMessagesAsRead: ${e.toString()}');
    }
  }
} 