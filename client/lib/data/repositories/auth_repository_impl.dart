import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
import 'package:sigmail_client/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/data/models/auth/create_user_model.dart';
import 'package:sigmail_client/data/models/auth/login_model.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
import 'package:sigmail_client/data/models/auth/refresh_token_request_model.dart';
import 'package:sigmail_client/core/error/exceptions.dart';

// Импорт для Result типа (можно использовать dartz или свой простой Result)
// import 'package:dartz/dartz.dart'; 
// import 'package:sigmail_client/core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final _controller = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  ) {
    // При инициализации пытаемся загрузить пользователя из кеша
    _localDataSource.getCachedUser().then((user) {
      _currentUser = user;
      _controller.add(_currentUser);
    });
  }

  @override
  Stream<UserModel?> get authStateChanges => _controller.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    _currentUser = await _localDataSource.getCachedUser();
    return _currentUser;
  }

  @override
  Future<AuthResultModel> login(LoginModel loginModel) async {
    // TODO: Обернуть в try-catch и возвращать Result<AuthResultModel, Failure>
    try {
      final authResult = await _remoteDataSource.login(loginModel);
      await _localDataSource.cacheAuthResult(authResult);
      _currentUser = authResult.user;
      _controller.add(_currentUser);
      return authResult;
    } on ServerException catch (e) {
      // Здесь можно мапить ServerException в Failure
      // Например, throw AuthFailure(message: e.message);
      // Пока просто пробрасываем для простоты
      rethrow;
    } catch (e) {
      // Обработка других непредвиденных ошибок
      rethrow;
    }
  }

  @override
  Future<AuthResultModel> register(CreateUserModel createUserModel) async {
    // TODO: Обернуть в try-catch и возвращать Result<AuthResultModel, Failure>
    try {
      final authResult = await _remoteDataSource.register(createUserModel);
      await _localDataSource.cacheAuthResult(authResult);
      _currentUser = authResult.user;
      _controller.add(_currentUser);
      return authResult;
    } on ServerException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    // TODO: Сообщить серверу о выходе, если есть такой эндпоинт
    // await _remoteDataSource.logout(); 
    await _localDataSource.clearAuthCache();
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AuthResultModel> refreshToken(String refreshTokenValue) async {
    try {
      final refreshTokenRequest = RefreshTokenRequestModel(refreshToken: refreshTokenValue);
      final newAuthResult = await _remoteDataSource.refreshToken(refreshTokenRequest);
      await _localDataSource.cacheAuthResult(newAuthResult); // Кешируем новый результат
      _currentUser = newAuthResult.user; // Обновляем текущего пользователя
      _controller.add(_currentUser); // Уведомляем подписчиков об изменении
      return newAuthResult;
    } on ServerException catch (e) {
      // Если обновление токена не удалось, возможно, refreshToken недействителен
      // В этом случае нужно очистить кеш и разлогинить пользователя
      await logout(); // Используем существующий метод logout для очистки
      rethrow; // Пробрасываем исключение дальше, чтобы interceptor понял, что обновление не удалось
    } catch (e) {
      await logout();
      rethrow;
    }
  }
} 