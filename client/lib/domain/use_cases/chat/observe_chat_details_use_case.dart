import 'dart:async';
import 'package:equatable/equatable.dart';
// import 'package:sigmail_client/core/use_case.dart'; // Больше не нужен UseCase
// import 'package:sigmail_client/core/stream_use_case.dart'; // <<< ИСПОЛЬЗУЕМ StreamUseCase
import 'package:sigmail_client/core/use_case.dart'; // <<< ИСПРАВЛЕННЫЙ ИМПОРТ
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
// import 'package:sigmail_client/core/use_case/use_case.dart';

class ObserveChatDetailsUseCase implements StreamUseCase<ChatModel, ObserveChatDetailsParams> {
  final ChatRepository repository;

  ObserveChatDetailsUseCase(this.repository);

  @override
  Stream<ChatModel> call(ObserveChatDetailsParams params) {
    return repository.observeChatDetails(params.chatId);
  }
}

class ObserveChatDetailsParams extends Equatable {
  final String chatId;

  const ObserveChatDetailsParams(this.chatId);

  @override
  List<Object> get props => [chatId];
}

// Удаляем старый ObserveChatUpdatesParams, если он все еще здесь
// class ObserveChatUpdatesParams extends Equatable {
//   final String chatId;
// 
//   const ObserveChatUpdatesParams(this.chatId);
// 
//   @override
//   List<Object> get props => [chatId];
// } 