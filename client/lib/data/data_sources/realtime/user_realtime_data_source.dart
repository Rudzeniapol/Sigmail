import 'dart:async';
import 'package:flutter/foundation.dart'; // Для kDebugMode
// import 'package:logging/logging.dart'; // Удаляем этот импорт
// import 'package:signalr_netcore/signalr_client.dart'; // УДАЛЯЕМ ЭТОТ ИМПОРТ
import 'package:signalr_core/signalr_core.dart'; // ИСПОЛЬЗУЕМ ЭТОТ ПАКЕТ
// import 'package:signalr_netcore/hub_connection.dart'; // УДАЛЯЕМ ЭТОТ ИМПОРТ
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Кажется, не используется здесь напрямую
// import 'package:sigmail_client/core/constants.dart'; // Кажется, не используется здесь напрямую
import 'package:sigmail_client/core/exceptions.dart'; // Раскомментировано
import 'package:logger/logger.dart'; // Оставляем этот логгер

// Определяем новый тип для события обновления аватара
class UserAvatarUpdate {
  final String userId;
  final String newAvatarUrl;
  UserAvatarUpdate({required this.userId, required this.newAvatarUrl});
}

abstract class UserRealtimeDataSource {
  Stream<UserModel> get userStatusStream;
  Stream<UserAvatarUpdate> get userAvatarUpdateStream;
  bool get isConnected;
  Future<void> connect();
  Future<void> disconnect();
  // void sendTypingStatus(String chatId, bool isTyping);
}

class UserRealtimeDataSourceImpl implements UserRealtimeDataSource {
  HubConnection? _hubConnection;
  final AuthLocalDataSource _authLocalDataSource = sl<AuthLocalDataSource>();
  final Logger _logger = Logger(); // Используем Logger из package:logger/logger.dart
  final String _hubUrl;
  final StreamController<UserModel> _userStatusController = StreamController.broadcast();
  final StreamController<UserAvatarUpdate> _userAvatarUpdateController = StreamController.broadcast();

  Timer? _reconnectTimer;

  UserRealtimeDataSourceImpl({
    required String hubUrl,
  })  : _hubUrl = hubUrl;

  @override
  Stream<UserModel> get userStatusStream => _userStatusController.stream;

  @override
  Stream<UserAvatarUpdate> get userAvatarUpdateStream => _userAvatarUpdateController.stream;

  @override
  bool get isConnected => _hubConnection?.state == HubConnectionState.connected;

  Future<String?> _getAccessToken() async {
    final authResult = await _authLocalDataSource.getLastAuthResult();
    return authResult?.accessToken;
  }

  @override
  Future<void> connect() async {
    _logger.i('[UserRealtimeDataSource] Connect method called.');
    final authResult = await _authLocalDataSource.getLastAuthResult();
    if (authResult == null) {
      _logger.w('[UserRealtimeDataSource] No auth result, cannot connect.');
      return;
    }

    if (_hubConnection?.state == HubConnectionState.connected ||
        _hubConnection?.state == HubConnectionState.connecting) {
      _logger.i('[UserRealtimeDataSource] Already connected or connecting.');
      return;
    }

    final hubUrl = AppConfig.signalRBaseUrl + _hubUrl; 

    // Для signalr_core, HttpConnectionOptions настраиваются иначе или не используются напрямую с withUrl так.
    // Токен доступа обычно передается через options в HubConnectionBuilder.
    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, HttpConnectionOptions(
          accessTokenFactory: () async {
            final token = await _getAccessToken();
            if (token == null) {
              _logger.w("Access token is null for SignalR connection. Returning empty string.");
              return ""; 
            }
            return token;
          },
          // logging: (level, message) => _logger.d('SignalR [${level.toString()}]: $message'), // У signalr_core другой механизм логгирования
        ))
        .withAutomaticReconnect()
        .build();
    
    // Колбэки в signalr_core могут иметь другие сигнатуры
    _hubConnection?.onclose((error) { // error может быть Object? или Exception?
      _logger.w('User status connection closed. Error: ${error?.toString()}');
    });

    _hubConnection?.onreconnecting((error) { // error может быть Object? или Exception?
      _logger.i('User status connection reconnecting. Error: ${error?.toString()}');
    });

    _hubConnection?.onreconnected((connectionId) { // connectionId может быть String?
      _logger.i('User status connection reconnected with ID: $connectionId');
    });

    _hubConnection?.on('UserStatusChanged', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 3) { 
        try {
          final userId = arguments[0] as String?;
          final isOnline = arguments[1] as bool?;
          final lastSeenString = arguments[2] as String?;

          if (userId == null || isOnline == null || lastSeenString == null) {
            _logger.w('UserStatusChanged called with null arguments. UserId: $userId, IsOnline: $isOnline, LastSeen: $lastSeenString');
            return;
          }
          
          final lastSeen = DateTime.tryParse(lastSeenString)?.toLocal();
          if (lastSeen == null) {
             _logger.w('UserStatusChanged: Could not parse lastSeen date: $lastSeenString');
            return;
          }

          final userModel = UserModel(
            id: userId,
            username: 'Unknown', 
            email: '', 
            isOnline: isOnline,
            lastSeen: lastSeen,
          );

          _userStatusController.add(userModel); 
          _logger.i('Received user status update for: $userId, Online: $isOnline, LastSeen: $lastSeenString');
        } catch (e, stackTrace) {
          _logger.e('Error deserializing UserStatusChanged event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.w('UserStatusChanged called with invalid arguments count: $arguments');
      }
    });

    // Новый обработчик для ReceiveUserAvatarUpdate
    _hubConnection?.on('ReceiveUserAvatarUpdate', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 2) {
        try {
          final userId = arguments[0] as String?;
          final newAvatarUrl = arguments[1] as String?;

          if (userId == null || newAvatarUrl == null) {
            _logger.w('ReceiveUserAvatarUpdate called with null arguments. UserId: $userId, NewAvatarUrl: $newAvatarUrl');
            return;
          }
          
          _userAvatarUpdateController.add(UserAvatarUpdate(userId: userId, newAvatarUrl: newAvatarUrl));
          _logger.i('Received user avatar update for: $userId, New URL: $newAvatarUrl');
        } catch (e, stackTrace) {
          _logger.e('Error deserializing ReceiveUserAvatarUpdate event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.w('ReceiveUserAvatarUpdate called with invalid arguments count: $arguments');
      }
    });

    try {
      await _hubConnection?.start();
      _logger.i('User status SignalR Connection started to $hubUrl');
    } catch (e) {
      _logger.e('User status SignalR Connection failed: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    if (_hubConnection != null && isConnected) {
      await _hubConnection!.stop();
      _logger.i('User status SignalR Connection Stopped.');
    } else {
      _logger.i('User status SignalR connection already stopped or not initialized.');
    }
  }
} 