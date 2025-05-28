import 'dart:async';
import 'package:flutter/foundation.dart'; // Для kDebugMode
// import 'package:logging/logging.dart'; // Удаляем этот импорт
// import 'package:signalr_netcore/signalr_client.dart'; // УДАЛЯЕМ ЭТОТ ИМПОРТ
import 'package:signalr_core/signalr_core.dart'; // ИСПОЛЬЗУЕМ ЭТОТ ПАКЕТ
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/typing/typing_event_model.dart'; // Импорт модели
import 'package:logger/logger.dart'; // Оставляем этот логгер
import 'package:sigmail_client/data/models/reaction/reaction_model.dart'; // <--- ДОБАВЛЕН ИМПОРТ

abstract class ChatRealtimeDataSource {
  Future<void> connect(String chatId);
  Future<void> disconnect(String chatId);
  Stream<MessageModel> observeMessages(String chatId);
  Stream<ChatModel> observeChatDetails(String chatId);
  Stream<TypingEventModel> get typingStatusEvents;
  Stream<Map<String, List<ReactionModel>>> observeMessageReactionsUpdate(String chatId); // <--- НОВЫЙ МЕТОД

  Future<void> sendUserIsTyping(String chatId);
  Future<void> sendUserStoppedTyping(String chatId);

  bool isConnected(String chatId);
  Future<void> dispose();
}

class ChatRealtimeDataSourceImpl implements ChatRealtimeDataSource {
  // Используем Map для управления несколькими соединениями или состояниями по chatId
  final Map<String, HubConnection> _hubConnections = {};
  final Map<String, StreamController<MessageModel>> _messageStreamControllers = {};
  final Map<String, StreamController<ChatModel>> _chatDetailsStreamControllers = {};
  final Map<String, StreamController<Map<String, List<ReactionModel>>>> _reactionUpdateStreamControllers = {}; // <--- НОВЫЙ StreamController
  
  // Общий StreamController для событий печати, так как они могут приходить для любого чата
  final StreamController<TypingEventModel> _typingStatusStreamController = StreamController<TypingEventModel>.broadcast();

  final AuthLocalDataSource _authLocalDataSource = sl<AuthLocalDataSource>();
  final Logger _logger = Logger(); // Используем Logger из package:logger/logger.dart

  static const String _chatHubUrl = '/chatHub';

  ChatRealtimeDataSourceImpl() {
    // Настройка уровня логирования для экземпляра _logger, если нужно
    // Либо глобально, если это единственный используемый логгер.
    // Logger.level = Level.info; // Для package:logger, если вы хотите установить глобальный уровень
  }

  Future<String?> _getAccessToken() async {
    final authResult = await _authLocalDataSource.getLastAuthResult();
    return authResult?.accessToken;
  }

  @override
  bool isConnected(String chatId) {
    if (!_hubConnections.containsKey(chatId)) return false;
    return _hubConnections[chatId]?.state == HubConnectionState.connected;
  }

  @override
  Stream<TypingEventModel> get typingStatusEvents => _typingStatusStreamController.stream;

  @override
  Future<void> connect(String chatId) async {
    _logger.i('[ChatRealtimeDataSource] Connect method called.');
    if (_hubConnections.containsKey(chatId) && 
        (_hubConnections[chatId]?.state == HubConnectionState.connected ||
         _hubConnections[chatId]?.state == HubConnectionState.connecting)) {
      _logger.i('[ChatRealtimeDataSource] Already connected or connecting.');
      return;
    }

    final hubUrl = AppConfig.signalRBaseUrl + _chatHubUrl;
    
    final hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, HttpConnectionOptions(
          accessTokenFactory: () async {
            final token = await _getAccessToken();
            if (token == null) {
              _logger.w("Access token is null for SignalR connection. Returning empty string.");
              return "";
            }
            return token;
          },
        ))
        .withAutomaticReconnect()
        .build();

    _hubConnections[chatId] = hubConnection;
    // Гарантируем, что StreamController создан для этого chatId
    _messageStreamControllers.putIfAbsent(chatId, () => StreamController<MessageModel>.broadcast());
    _chatDetailsStreamControllers.putIfAbsent(chatId, () => StreamController<ChatModel>.broadcast());
    _reactionUpdateStreamControllers.putIfAbsent(chatId, () => StreamController<Map<String, List<ReactionModel>>>.broadcast()); // <--- ИНИЦИАЛИЗАЦИЯ КОНТРОЛЛЕРА

    hubConnection.onclose((error) { // ИЗМЕНЕНО: именованный параметр
      _logger.w('Connection for chat $chatId closed. Error: ${error?.toString()}');
      // Можно добавить логику для очистки контроллеров, если соединение не будет восстановлено
      // _messageStreamControllers[chatId]?.close();
      // _chatDetailsStreamControllers[chatId]?.close();
      // _hubConnections.remove(chatId);
    });

    hubConnection.onreconnecting((error) { // ИЗМЕНЕНО: именованный параметр
      _logger.i('Connection for chat $chatId reconnecting. Error: ${error?.toString()}');
    });

    hubConnection.onreconnected((connectionId) { // ИЗМЕНЕНО: именованный параметр
      _logger.i('Connection for chat $chatId reconnected with ID: $connectionId');
      // Возможно, потребуется перезапросить начальное состояние или заново подписаться на группы
      // Например, вызвать JoinChatGroup на сервере, если вы его используете
      // hubConnection.invoke('JoinChatGroup', args: [chatId]);
    });

    // Обработчик для новых сообщений
    hubConnection.on('ReceiveMessage', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final messageData = arguments[0] as Map<String, dynamic>?;
          if (messageData != null) {
            final message = MessageModel.fromJson(messageData);
            if (message.chatId == chatId) { // Убедимся, что сообщение для текущего чата
              _messageStreamControllers[chatId]?.add(message);
              _logger.i('Received message for chat $chatId: ${message.id}');
            } else {
              _logger.i('Received message for another chat ${message.chatId}, current chat is $chatId. Ignoring for this controller.');
            }
          } else {
            _logger.w('ReceiveMessage called with null message data.');
          }
        } catch (e, stackTrace) {
          _logger.e('Error deserializing ReceiveMessage event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.w('ReceiveMessage called with invalid arguments: $arguments');
      }
    });

    // Обработчик для обновления деталей чата (включая lastMessage)
    hubConnection.on('ChatDetailsUpdated', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final chatData = arguments[0] as Map<String, dynamic>?;
          if (chatData != null) {
            if (chatData.containsKey('lastMessage')) {
              _logger.i('Raw lastMessage from SignalR for chat ${chatData['id']}: ${chatData['lastMessage']}');
            }
            _logger.i('ChatDetailsUpdated: Raw chatData before ChatModel.fromJson for chat ${chatData['id']}: $chatData');
            final chat = ChatModel.fromJson(chatData);
            if (chat.id == chatId) { // Убедимся, что обновление для текущего чата
              _chatDetailsStreamControllers[chatId]?.add(chat);
              _logger.i('Chat details updated for chat $chatId, LastMessage: ${chat.lastMessage?.id}, Text: ${chat.lastMessage?.text}');
            } else {
               _logger.i('Received ChatDetailsUpdated for another chat ${chat.id}, current chat is $chatId. Ignoring for this controller.');
            }
          } else {
             _logger.w('ChatDetailsUpdated called with null chat data.');
          }
        } catch (e, stackTrace) {
          _logger.e('Error deserializing ChatDetailsUpdated event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.w('ChatDetailsUpdated called with invalid arguments: $arguments');
      }
    });

    // Обработчики для статуса печати (глобальные для всех соединений, так как _typingStatusStreamController один)
    // Эти обработчики будут добавлены только один раз, если _typingStatusStreamController еще не имеет слушателей этих событий
    // Однако, SignalR клиент позволяет добавлять несколько обработчиков на одно и то же событие.
    // Чтобы избежать многократной регистрации, можно было бы проверить, не зарегистрированы ли они уже,
    // но для .on() это не так просто. Вместо этого, обеспечим, что логика внутри вызывается корректно.
    // Поскольку _typingStatusStreamController глобальный, эти события будут обрабатываться для всех чатов.

    // Убедимся, что глобальные обработчики событий печати регистрируются только один раз,
    // если мы используем один _hubConnection для всех чатов или если это первое соединение.
    // В текущей реализации с _hubConnections[chatId] = hubConnection, каждый чат имеет свое соединение.
    // Если так, то эти обработчики должны быть на каждом hubConnection.
    
    // Проверяем, не были ли уже зарегистрированы обработчики для UserTypingInChat и UserStoppedTypingInChat
    // Это простая проверка, чтобы не дублировать слушатели на одном и том же инстансе hubConnection.
    // ВНИМАНИЕ: SignalR не предоставляет стандартного способа проверить, есть ли уже обработчик.
    // Эта логика предполагает, что если мы добавляем их здесь, то они нужны.
    // Если логика регистрации/отписки сложнее, ее нужно будет пересмотреть.

    hubConnection.on('UserTypingInChat', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 3) {
        try {
          final eventChatId = arguments[0] as String;
          final userId = arguments[1] as String;
          final username = arguments[2] as String;
          _typingStatusStreamController.add(TypingEventModel(
            chatId: eventChatId,
            userId: userId,
            username: username,
            isTyping: true,
          ));
          _logger.i('Received UserTypingInChat: User $username ($userId) in chat $eventChatId');
        } catch (e) {
          _logger.e('Error processing UserTypingInChat: $e, args: $arguments');
        }
      }
    });

    hubConnection.on('UserStoppedTypingInChat', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 3) {
        try {
          final eventChatId = arguments[0] as String;
          final userId = arguments[1] as String;
          final username = arguments[2] as String; 
          _typingStatusStreamController.add(TypingEventModel(
            chatId: eventChatId,
            userId: userId,
            username: username,
            isTyping: false,
          ));
          _logger.i('Received UserStoppedTypingInChat: User $username ($userId) in chat $eventChatId');
        } catch (e) {
          _logger.e('Error processing UserStoppedTypingInChat: $e, args: $arguments');
        }
      }
    });

    // Обработчик для обновления реакций
    hubConnection.on('ReceiveMessageReactionsUpdate', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 3) {
        try {
          final eventChatId = arguments[0] as String?;
          final messageId = arguments[1] as String?;
          final reactionsData = arguments[2] as List<dynamic>?;

          if (eventChatId != null && messageId != null && reactionsData != null && eventChatId == chatId) {
            final reactions = reactionsData
                .map((data) => ReactionModel.fromJson(data as Map<String, dynamic>))
                .toList();
            _reactionUpdateStreamControllers[chatId]?.add({messageId: reactions});
            _logger.i('Received reaction update for chat $chatId, message $messageId');
          } else {
            _logger.w('ReceiveMessageReactionsUpdate called with invalid data or for wrong chat. ChatID: $eventChatId, MsgID: $messageId, CurrentChat: $chatId');
          }
        } catch (e, stackTrace) {
          _logger.e('Error deserializing ReceiveMessageReactionsUpdate event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.w('ReceiveMessageReactionsUpdate called with invalid arguments: $arguments');
      }
    });

    try {
      await hubConnection.start();
      _logger.i('SignalR Connection started for chat $chatId to $hubUrl');
      // Если вы используете группы SignalR на сервере:
      // await hubConnection.invoke('JoinChatGroup', args: [chatId]);
      // _logger.info('Joined SignalR group for chat $chatId');
    } catch (e) {
      _logger.e('SignalR Connection for chat $chatId failed: $e');
    }
  }

  @override
  Stream<MessageModel> observeMessages(String chatId) {
    // Гарантируем, что StreamController существует
    _messageStreamControllers.putIfAbsent(chatId, () => StreamController<MessageModel>.broadcast());
    // Если соединение еще не установлено для этого чата, можно его инициировать здесь
    // if (!_hubConnections.containsKey(chatId) || _hubConnections[chatId]?.state == HubConnectionState.Disconnected) {
    //   connect(chatId); 
    // }
    return _messageStreamControllers[chatId]!.stream;
  }

  @override
  Stream<ChatModel> observeChatDetails(String chatId) {
    _chatDetailsStreamControllers.putIfAbsent(chatId, () => StreamController<ChatModel>.broadcast());
    return _chatDetailsStreamControllers[chatId]!.stream;
  }

  @override
  Stream<Map<String, List<ReactionModel>>> observeMessageReactionsUpdate(String chatId) {
    _reactionUpdateStreamControllers.putIfAbsent(chatId, () => StreamController<Map<String, List<ReactionModel>>>.broadcast());
    return _reactionUpdateStreamControllers[chatId]!.stream;
  }

  @override
  Future<void> disconnect(String chatId) async {
    if (_hubConnections.containsKey(chatId)) {
      final hubConnection = _hubConnections[chatId];
      if (hubConnection?.state == HubConnectionState.connected) { 
        // Если вы использовали группы SignalR:
        // await hubConnection.invoke('LeaveChatGroup', args: [chatId]);
        await hubConnection!.stop();
        _logger.i('SignalR Connection for chat $chatId stopped.');
      }
      _hubConnections.remove(chatId);
      _messageStreamControllers[chatId]?.close();
      _messageStreamControllers.remove(chatId);
      _chatDetailsStreamControllers[chatId]?.close();
      _chatDetailsStreamControllers.remove(chatId);
      _reactionUpdateStreamControllers[chatId]?.close(); // <--- ЗАКРЫТИЕ КОНТРОЛЛЕРА
    } else {
      _logger.i('SignalR connection for chat $chatId already stopped or not initialized.');
    }
    // Глобальный _typingStatusStreamController не закрываем здесь, он может быть нужен другим чатам.
    // Его закрытие должно происходить, когда весь ChatRealtimeDataSourceImpl больше не нужен.
  }

  // Реализация новых методов
  @override
  Future<void> sendUserIsTyping(String chatId) async {
    if (isConnected(chatId)) {
      try {
        // Убедимся, что используем правильное соединение для этого чата
        await _hubConnections[chatId]!.invoke('UserIsTyping', args: [chatId]);
        _logger.i('Sent UserIsTyping for chat $chatId');
      } catch (e) {
        _logger.e('Error sending UserIsTyping for chat $chatId: $e');
      }
    } else {
      _logger.w('Cannot send UserIsTyping, not connected. Chat: $chatId');
    }
  }

  @override
  Future<void> sendUserStoppedTyping(String chatId) async {
    if (isConnected(chatId)) {
      try {
        await _hubConnections[chatId]!.invoke('UserStoppedTyping', args: [chatId]);
        _logger.i('Sent UserStoppedTyping for chat $chatId');
      } catch (e) {
        _logger.e('Error sending UserStoppedTyping for chat $chatId: $e');
      }
    } else {
      _logger.w('Cannot send UserStoppedTyping, not connected. Chat: $chatId');
    }
  }

  // Метод для очистки всех ресурсов, если это необходимо при выходе из приложения или разлогине
  Future<void> dispose() async {
    _logger.i('Disposing ChatRealtimeDataSourceImpl...');
    for (var chatId in _hubConnections.keys.toList()) { // toList() для избежания изменения коллекции во время итерации
      await disconnect(chatId);
    }
    _hubConnections.clear();
    _messageStreamControllers.forEach((_, controller) => controller.close());
    _messageStreamControllers.clear();
    _chatDetailsStreamControllers.forEach((_, controller) => controller.close());
    _chatDetailsStreamControllers.clear();
    _reactionUpdateStreamControllers.forEach((_, controller) => controller.close()); // <--- ОЧИСТКА MAP
    await _typingStatusStreamController.close(); // Закрываем глобальный контроллер здесь
    _logger.i('ChatRealtimeDataSourceImpl disposed.');
  }

  Future<void> ensureConnection(String chatId) async {
    if (!(_hubConnections.containsKey(chatId) &&
        (_hubConnections[chatId]?.state == HubConnectionState.connected ||
         _hubConnections[chatId]?.state == HubConnectionState.connecting))) {
      await connect(chatId);
    }
  }
} 