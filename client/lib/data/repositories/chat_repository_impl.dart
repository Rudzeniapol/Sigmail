import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failure.dart';
import 'package:sigmail_client/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/realtime/chat_realtime_data_source.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/chat/create_chat_model.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/reaction/reaction_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
import 'package:sigmail_client/core/exceptions.dart';
// import 'package:dartz/dartz.dart'; // Для обработки ошибок с Either
// import 'package:sigmail_client/core/error/failures.dart';
// import 'package:sigmail_client/core/network/network_info.dart'; // Для проверки сети, если нужно

// Импорты для вложений
import 'package:cross_file/cross_file.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_request_model.dart';
import 'package:sigmail_client/data/models/attachment/presigned_url_response_model.dart';
import 'package:sigmail_client/data/models/attachment/create_message_with_attachment_client_dto.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final ChatRealtimeDataSource _realtimeDataSource; 
  // final NetworkInfo _networkInfo; // Если будете проверять состояние сети

  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ChatRealtimeDataSource realtimeDataSource,
    // required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _realtimeDataSource = realtimeDataSource;
        // _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ChatModel>>> getChats({int pageNumber = 1, int pageSize = 20}) async {
    // TODO: Добавить проверку сети, если _networkInfo используется
    // TODO: Добавить обработку ошибок с Either<Failure, List<ChatModel>>
    try {
      // Закомментируем вызов connect здесь, т.к. он требует chatId и нелогичен для getChats
      // await _realtimeDataSource.connect(); 
      final chats = await _remoteDataSource.getChats(pageNumber: pageNumber, pageSize: pageSize);
      return Right(chats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при загрузке чатов'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при загрузке чатов: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChatModel>> getChatById(String chatId) async {
    try {
      final chat = await _remoteDataSource.getChatById(chatId);
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при загрузке чата'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при загрузке чата: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ChatModel>> createChat(CreateChatModel createChatModel) async {
    try {
      final chat = await _remoteDataSource.createChat(createChatModel);
      // После создания чата можно, например, автоматически подписаться на его обновления
      // observeMessages(chat.id); 
      // observeChatUpdates(chat.id);
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при создании чата'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при создании чата: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getChatMessages(String chatId, {int pageNumber = 1, int pageSize = 50}) async {
    try {
      // При получении сообщений чата, также убедимся, что есть подписка на новые
      // observeMessages(chatId); // Это можно делать и при открытии экрана чата
      final messages = await _remoteDataSource.getChatMessages(chatId, pageNumber: pageNumber, pageSize: pageSize);
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при загрузке сообщений'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при загрузке сообщений: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage(CreateMessageModel messageModel) async {
    try {
      // Отправка сообщения может идти через HTTP API
      final sentMessage = await _remoteDataSource.sendMessage(messageModel);
      // SignalR на сервере должен сам разослать это сообщение всем подписчикам этого чата,
      // включая текущего пользователя, так что оно придет через observeMessages.
      // Если бы отправка шла через SignalR invoke, то не нужно было бы ждать ответа здесь.
      return Right(sentMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при отправке сообщения'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при отправке сообщения: ${e.toString()}'));
    }
  }

  @override
  Stream<MessageModel> observeMessages(String chatId) {
    _realtimeDataSource.connect(chatId); // Передаем chatId
    return _realtimeDataSource.observeMessages(chatId);
  }

  @override
  Stream<ChatModel> observeChatDetails(String chatId) { // Переименовано с observeChatUpdates
    _realtimeDataSource.connect(chatId); // Передаем chatId
    return _realtimeDataSource.observeChatDetails(chatId); // Используем observeChatDetails
  }
  
  Future<void> disconnectRealtimeForChat(String chatId) async { // Переименовано и принимает chatId
    await _realtimeDataSource.disconnect(chatId); // Передаем chatId
  }

  // Реализация новых методов для вложений
  @override
  Future<Either<Failure, PresignedUrlResponseModel>> getPresignedUploadUrl(PresignedUrlRequestModel request) async {
    try {
      final response = await _remoteDataSource.getPresignedUploadUrl(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при получении URL для загрузки'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при получении URL для загрузки: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> uploadFileToS3(String presignedUrl, XFile file, String? contentType) async {
    try {
      await _remoteDataSource.uploadFileToS3(presignedUrl, file, contentType);
      return const Right(null); // Успех, возвращаем void (null в Right)
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при загрузке файла в S3'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при загрузке файла в S3: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessageWithAttachment(CreateMessageWithAttachmentClientDto dto) async {
    try {
      final message = await _remoteDataSource.sendMessageWithAttachment(dto);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при отправке сообщения с вложением'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при отправке сообщения с вложением: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReactionModel>>> addReaction(String messageId, String emoji) async {
    try {
      final reactions = await _remoteDataSource.addReaction(messageId, emoji);
      return Right(reactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при добавлении реакции'));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при добавлении реакции: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReactionModel>>> removeReaction(String messageId, String emoji) async {
    try {
      final reactions = await _remoteDataSource.removeReaction(messageId, emoji);
      return Right(reactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при удалении реакции'));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при удалении реакции: ${e.toString()}'));
    }
  }

  @override
  Stream<Map<String, List<ReactionModel>>> observeMessageReactionsUpdate(String chatId) {
    _realtimeDataSource.connect(chatId); // Убедимся, что соединение установлено
    return _realtimeDataSource.observeMessageReactionsUpdate(chatId);
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String chatId) async {
    try {
      await _remoteDataSource.markMessagesAsRead(chatId);
      return const Right(null); // Успех, возвращаем void (null в Right)
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Ошибка сервера при пометке сообщений как прочитанных'));
    } catch (e) {
      return Left(UnknownFailure('Неизвестная ошибка при пометке сообщений как прочитанных: ${e.toString()}'));
    }
  }
} 