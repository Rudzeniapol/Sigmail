import 'dart:async';
import 'package:flutter/foundation.dart'; // Для kDebugMode
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';

abstract class UserRealtimeDataSource {
  Future<void> connect();
  Future<void> disconnect();
  Stream<UserModel> observeUserStatus();
  bool get isConnected;
}

class UserRealtimeDataSourceImpl implements UserRealtimeDataSource {
  HubConnection? _hubConnection;
  final AuthLocalDataSource _authLocalDataSource = sl<AuthLocalDataSource>();
  final Logger _logger = Logger('UserRealtimeDataSource');

  // Контроллер для трансляции событий статуса пользователя
  // В данном случае нам нужен один контроллер, т.к. мы слушаем обновления всех пользователей,
  // или пользователей, с которыми у нас есть чаты.
  // Если сервер шлет обновления статуса конкретного пользователя по его ID, 
  // то можно использовать Map<String, StreamController<UserModel>> как в ChatRealtimeDataSource
  final StreamController<UserModel> _userStatusStreamController = StreamController<UserModel>.broadcast();

  static const String _userHubUrl = '/chathub'; // ИЗМЕНЕННЫЙ ПУТЬ НА ОСНОВАНИИ КОНФИГУРАЦИИ СЕРВЕРА

  @override
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  UserRealtimeDataSourceImpl() {
    if (kDebugMode) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((LogRecord rec) {
        print('[${rec.level.name}] ${rec.time}: ${rec.loggerName}: ${rec.message}');
      });
    }
  }

  Future<String?> _getAccessToken() async {
    final authResult = await _authLocalDataSource.getLastAuthResult();
    return authResult?.accessToken;
  }

  @override
  Future<void> connect() async {
    if (_hubConnection?.state == HubConnectionState.Connected ||
        _hubConnection?.state == HubConnectionState.Connecting) {
      _logger.info("User status connection already exists or is in progress.");
      return;
    }

    final hubUrl = AppConfig.signalRBaseUrl + _userHubUrl; 

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () => _getAccessToken().then((String? token) => Future.value(token)),
            ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({Exception? error}) {
      _logger.warning('User status connection closed. Error: ${error?.toString()}');
    });

    _hubConnection?.onreconnecting(({Exception? error}) {
      _logger.info('User status connection reconnecting. Error: ${error?.toString()}');
    });

    _hubConnection?.onreconnected(({String? connectionId}) {
      _logger.info('User status connection reconnected with ID: $connectionId');
    });

    // Регистрируем метод, который сервер будет вызывать для обновления статуса пользователя
    _hubConnection?.on('UserStatusChanged', (List<Object?>? arguments) {
      if (arguments != null && arguments.length == 3) { // Ожидаем 3 аргумента: userId (Guid -> String), isOnline (bool), lastSeen (DateTime -> String)
        try {
          final userId = arguments[0] as String?;
          final isOnline = arguments[1] as bool?;
          final lastSeenString = arguments[2] as String?;

          if (userId == null || isOnline == null || lastSeenString == null) {
            _logger.warning('UserStatusChanged called with null arguments. UserId: $userId, IsOnline: $isOnline, LastSeen: $lastSeenString');
            return;
          }
          
          final lastSeen = DateTime.tryParse(lastSeenString)?.toLocal();
          if (lastSeen == null) {
             _logger.warning('UserStatusChanged: Could not parse lastSeen date: $lastSeenString');
            return;
          }

          // Так как у нас нет полного UserModel, а только его части, 
          // и наш _userStatusStreamController ожидает UserModel,
          // нам нужно либо изменить _userStatusStreamController на Stream<UserStatusUpdateData>,
          // либо здесь конструировать UserModel (что может быть неполным, если UserModel содержит больше полей).
          //
          // Вариант 1: Отправлять неполный UserModel (только с обновленными полями)
          // Это потребует, чтобы UserModel имел необязательные поля или конструктор, который может их принять.
          // Предположим, что конструктор UserModel.fromJson может обрабатывать частичные данные или у нас есть UserStatusModel.
          // Для простоты, создадим новый UserModel с полученными данными.
          // Нам нужен username, который мы здесь не получаем от сервера. Это проблема.
          //
          // Лучшим решением было бы, если бы сервер отправлял полный UserDto/UserModel.
          // Поскольку сервер отправляет UserDto, а метод UserStatusChanged в IChatHubClient принимает (Guid userId, bool isOnline, DateTime lastSeen),
          // то сервер в SignalRChatHub должен был бы отправлять UserDto целиком, и клиент бы его десериализовал.
          //
          // Текущий IChatHubClient.UserStatusChanged не соответствует отправке полного UserDto.
          // Давайте вернемся к варианту, когда сервер отправляет полный UserDto, а клиент его слушает.
          // Это значит, что в IChatHubClient должен быть метод вроде `ReceiveUserStatusUpdate(UserDto user)`
          // А в SignalRChatHub.cs мы вызывали бы его.
          //
          // Поскольку мы уже изменили SignalRChatHub.cs на Clients.All.UserStatusChanged(updatedUser.Id, updatedUser.IsOnline, updatedUser.LastSeen ?? DateTime.UtcNow);
          // нам нужно, чтобы клиентский UserModel мог быть создан или обновлен из этих трех полей.
          // Это сложно, если у нас нет существующего UserModel для этого userId, чтобы обновить его.

          // Временное решение: создаем UserModel с тем, что есть, username будет пустым.
          // Это не идеально, но позволит проверить механику.
          // В идеале, либо UserStatusBloc должен хранить Map<String, UserModel> и обновлять его, 
          // либо сервер должен присылать достаточно данных для создания полного UserModel.
          final userModel = UserModel(
            id: userId,
            username: 'Unknown', // Мы не получаем username в этом событии
            email: '', // Мы не получаем email
            isOnline: isOnline,
            lastSeen: lastSeen,
            // profileImageUrl: null, // и другие поля будут дефолтными/null
          );

          _userStatusStreamController.add(userModel); 
          _logger.info('Received user status update for: $userId, Online: $isOnline, LastSeen: $lastSeenString');
        } catch (e, stackTrace) {
          _logger.severe('Error deserializing UserStatusChanged event: $e\n$stackTrace, arguments: $arguments');
        }
      } else {
        _logger.warning('UserStatusChanged called with invalid arguments count: $arguments');
      }
    });

    try {
      await _hubConnection?.start();
      _logger.info('User status SignalR Connection started to $hubUrl');
    } catch (e) {
      _logger.severe('User status SignalR Connection failed: $e');
    }
  }

  @override
  Stream<UserModel> observeUserStatus() {
    if (!isConnected) {
      _logger.warning('User status SignalR not connected. Call connect() first.');
      // Можно добавить автоматическое подключение, если необходимо
      // connect(); 
    }
    return _userStatusStreamController.stream;
  }

  @override
  Future<void> disconnect() async {
    if (_hubConnection != null && isConnected) {
      await _hubConnection!.stop();
      _logger.info('User status SignalR Connection Stopped.');
    } else {
      _logger.info('User status SignalR connection already stopped or not initialized.');
    }
    // Не забываем закрыть контроллер, если он больше не нужен, 
    // но в данном случае он может быть активен пока приложение работает.
    // Если UserRealtimeDataSource создается и уничтожается часто, то нужно закрывать:
    // await _userStatusStreamController.close(); 
  }
} 