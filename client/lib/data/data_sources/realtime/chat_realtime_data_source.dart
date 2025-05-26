import 'dart:async';
import 'package:flutter/foundation.dart'; // Для kDebugMode
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/typing/typing_event_model.dart'; // Импорт модели

abstract class ChatRealtimeDataSource {
  Future<void> connect(String chatId);
  Future<void> disconnect(String chatId);
  Stream<MessageModel> observeMessages(String chatId);
  Stream<ChatModel> observeChatDetails(String chatId);
  Stream<TypingEventModel> get typingStatusEvents;

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
  
  // Общий StreamController для событий печати, так как они могут приходить для любого чата
  final StreamController<TypingEventModel> _typingStatusStreamController = StreamController<TypingEventModel>.broadcast();

  final AuthLocalDataSource _authLocalDataSource = sl<AuthLocalDataSource>();
  final Logger _logger = Logger('ChatRealtimeDataSource');

  static const String _chatHubUrl = '/chatHub';

  ChatRealtimeDataSourceImpl() {
    if (kDebugMode) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((LogRecord rec) {
        // TODO: Убрать или настроить этот глобальный обработчик, если он мешает
        // print('[${rec.level.name}] ${rec.time}: ${rec.loggerName}: ${rec.message}');
      });
    }
  }

  Future<String?> _getAccessToken() async {
    final authResult = await _authLocalDataSource.getLastAuthResult();
    return authResult?.accessToken;
  }

  @override
  bool isConnected(String chatId) => 
      _hubConnections[chatId]?.state == HubConnectionState.Connected;

  @override
  Stream<TypingEventModel> get typingStatusEvents => _typingStatusStreamController.stream;

  @override
  Future<void> connect(String chatId) async {
    if (_hubConnections.containsKey(chatId) && 
        (_hubConnections[chatId]?.state == HubConnectionState.Connected ||
         _hubConnections[chatId]?.state == HubConnectionState.Connecting)) {
      _logger.info('Connection for chat $chatId already exists or is in progress.');
      return;
    }

    final hubUrl = AppConfig.signalRBaseUrl + _chatHubUrl;
    final hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () => _getAccessToken().then((String? token) => Future.value(token)),
            ))
        .withAutomaticReconnect()
        .build();

    _hubConnections[chatId] = hubConnection;
    // Гарантируем, что StreamController создан для этого chatId
    _messageStreamControllers.putIfAbsent(chatId, () => StreamController<MessageModel>.broadcast());
    _chatDetailsStreamControllers.putIfAbsent(chatId, () => StreamController<ChatModel>.broadcast());

    hubConnection.onclose(({Exception? error}) {
      _logger.warning('Connection for chat $chatId closed. Error: ${error?.toString()}');
      // Можно добавить логику для очистки контроллеров, если соединение не будет восстановлено
      // _messageStreamControllers[chatId]?.close();
      // _chatDetailsStreamControllers[chatId]?.close();
      // _hubConnections.remove(chatId);
    });

    hubConnection.onreconnecting(({Exception? error}) {
      _logger.info('Connection for chat $chatId reconnecting. Error: ${error?.toString()}');
    });

    hubConnection.onreconnected(({String? connectionId}) {
      _logger.info('Connection for chat $chatId reconnected with ID: $connectionId');
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
              _logger.info('Received message for chat $chatId: ${message.id}');
            } else {
              _logger.info('Received message for another chat ${message.chatId}, current chat is $chatId. Ignoring for this controller.');
            }
          } else {
            _logger.warning('ReceiveMessage called with null message data.');
          }
        } catch (e, stackTrace) {
          _logger.severe('Error deserializing ReceiveMessage event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.warning('ReceiveMessage called with invalid arguments: $arguments');
      }
    });

    // Обработчик для обновления деталей чата (включая lastMessage)
    hubConnection.on('ChatDetailsUpdated', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final chatData = arguments[0] as Map<String, dynamic>?;
          if (chatData != null) {
            if (chatData.containsKey('lastMessage')) {
              _logger.info('Raw lastMessage from SignalR for chat ${chatData['id']}: ${chatData['lastMessage']}');
            }
            final chat = ChatModel.fromJson(chatData);
            if (chat.id == chatId) { // Убедимся, что обновление для текущего чата
              _chatDetailsStreamControllers[chatId]?.add(chat);
              _logger.info('Chat details updated for chat $chatId, LastMessage: ${chat.lastMessage?.id}, Text: ${chat.lastMessage?.text}');
            } else {
               _logger.info('Received ChatDetailsUpdated for another chat ${chat.id}, current chat is $chatId. Ignoring for this controller.');
            }
          } else {
             _logger.warning('ChatDetailsUpdated called with null chat data.');
          }
        } catch (e, stackTrace) {
          _logger.severe('Error deserializing ChatDetailsUpdated event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.warning('ChatDetailsUpdated called with invalid arguments: $arguments');
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
          _logger.info('Received UserTypingInChat: User $username ($userId) in chat $eventChatId');
        } catch (e) {
          _logger.severe('Error processing UserTypingInChat: $e, args: $arguments');
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
          _logger.info('Received UserStoppedTypingInChat: User $username ($userId) in chat $eventChatId');
        } catch (e) {
          _logger.severe('Error processing UserStoppedTypingInChat: $e, args: $arguments');
        }
      }
    });

    try {
      await hubConnection.start();
      _logger.info('SignalR Connection started for chat $chatId to $hubUrl');
      // Если вы используете группы SignalR на сервере:
      // await hubConnection.invoke('JoinChatGroup', args: [chatId]);
      // _logger.info('Joined SignalR group for chat $chatId');
    } catch (e) {
      _logger.severe('SignalR Connection for chat $chatId failed: $e');
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
  Future<void> disconnect(String chatId) async {
    if (_hubConnections.containsKey(chatId)) {
      final hubConnection = _hubConnections[chatId];
      if (hubConnection?.state == HubConnectionState.Connected) {
        // Если вы использовали группы SignalR:
        // await hubConnection.invoke('LeaveChatGroup', args: [chatId]);
        // _logger.info('Left SignalR group for chat $chatId');
        await hubConnection!.stop();
        _logger.info('SignalR Connection for chat $chatId stopped.');
      }
      _hubConnections.remove(chatId);
      _messageStreamControllers[chatId]?.close();
      _messageStreamControllers.remove(chatId);
      _chatDetailsStreamControllers[chatId]?.close();
      _chatDetailsStreamControllers.remove(chatId);
    } else {
      _logger.info('SignalR connection for chat $chatId already stopped or not initialized.');
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
        _logger.info('Sent UserIsTyping for chat $chatId');
      } catch (e) {
        _logger.severe('Error sending UserIsTyping for chat $chatId: $e');
      }
    } else {
      _logger.warning('Cannot send UserIsTyping, not connected. Chat: $chatId');
    }
  }

  @override
  Future<void> sendUserStoppedTyping(String chatId) async {
    if (isConnected(chatId)) {
      try {
        await _hubConnections[chatId]!.invoke('UserStoppedTyping', args: [chatId]);
        _logger.info('Sent UserStoppedTyping for chat $chatId');
      } catch (e) {
        _logger.severe('Error sending UserStoppedTyping for chat $chatId: $e');
      }
    } else {
      _logger.warning('Cannot send UserStoppedTyping, not connected. Chat: $chatId');
    }
  }

  // Метод для очистки всех ресурсов, если это необходимо при выходе из приложения или разлогине
  Future<void> dispose() async {
    _logger.info('Disposing ChatRealtimeDataSourceImpl...');
    for (var chatId in _hubConnections.keys.toList()) { // toList() для избежания изменения коллекции во время итерации
      await disconnect(chatId);
    }
    _hubConnections.clear();
    _messageStreamControllers.forEach((_, controller) => controller.close());
    _messageStreamControllers.clear();
    _chatDetailsStreamControllers.forEach((_, controller) => controller.close());
    _chatDetailsStreamControllers.clear();
    await _typingStatusStreamController.close(); // Закрываем глобальный контроллер здесь
    _logger.info('ChatRealtimeDataSourceImpl disposed.');
  }
} 