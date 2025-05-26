import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // для kDebugMode
import 'package:sigmail_client/core/injection_container.dart'; // Для sl
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart'; 
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';

class AuthInterceptor extends Interceptor {
  // Мы не можем напрямую внедрять AuthBloc или AuthRepository сюда,
  // так как это может создать циклические зависимости при инициализации GetIt,
  // если Dio инициализируется раньше, чем AuthBloc/AuthRepository полностью готовы.
  // Лучше всего получать AuthLocalDataSource через sl()
  // и из него доставать токен.

  // Флаг, чтобы предотвратить бесконечный цикл запросов на обновление токена
  bool _isRefreshing = false;

  // Очередь для запросов, которые ожидают обновления токена
  final List<Function(String)> _requestQueue = [];

  Dio get _dio => sl<Dio>(); // Получаем экземпляр Dio для повторных запросов

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Пути, которые не требуют токена аутентификации
    const noAuthPaths = ['/auth/login', '/auth/register', '/auth/refresh-token'];

    if (noAuthPaths.any((path) => options.path.endsWith(path))) {
      return handler.next(options); // Пропускаем добавление токена
    }

    final localDataSource = sl<AuthLocalDataSource>();
    AuthResultModel? authResult = await localDataSource.getLastAuthResult();

    if (authResult?.accessToken != null) {
      // Проактивное обновление токена
      if (authResult!.accessTokenExpiration.isBefore(DateTime.now().add(const Duration(minutes: 1))) && 
          authResult.refreshToken.isNotEmpty) { // Проверяем, что refreshToken не пустой
        
        if (!_isRefreshing) {
          _isRefreshing = true;
          if (kDebugMode) {
            print('[AuthInterceptor-onRequest] Proactive refresh: Access token expiring soon or expired. Attempting to refresh...');
            print('[AuthInterceptor-onRequest] Current time: ${DateTime.now()}, Expiration: ${authResult.accessTokenExpiration}');
          }
          try {
            final authRepository = sl<AuthRepository>();
            final newAuthResult = await authRepository.refreshToken(authResult.refreshToken);
            if (kDebugMode) {
              print('[AuthInterceptor-onRequest] Proactive refresh: Token refreshed successfully. New expiration: ${newAuthResult.accessTokenExpiration}');
            }
            authResult = newAuthResult; // Используем новый authResult для текущего запроса
                                        // AuthRepository должен сам позаботиться о кешировании
            _isRefreshing = false;
            _processQueue(newAuthResult.accessToken); // Обрабатываем очередь, если она была
          } catch (e) {
            if (kDebugMode) {
              print('[AuthInterceptor-onRequest] Proactive refresh: Token refresh failed: $e. Request will proceed with old/expired token.');
            }
            _isRefreshing = false;
            // Не прерываем запрос и не чистим очередь здесь. Даем шанс сработать onError.
          }
        }
      }
      options.headers['Authorization'] = 'Bearer ${authResult!.accessToken}';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.endsWith('/auth/refresh-token')) {
        if (kDebugMode) {
          print('[AuthInterceptor-onError] Refresh token request itself failed. Logging out.');
        }
        final authRepository = sl<AuthRepository>();
        await authRepository.logout();
        _isRefreshing = false; // Сбрасываем флаг на всякий случай
        _clearQueueAndReject(err, handler); // Отклоняем текущий и все ожидающие запросы
        return; // Важно не вызывать handler.reject(err) дважды
      }

      if (_isRefreshing) {
        if (kDebugMode) {
            print('[AuthInterceptor-onError] Token refresh already in progress. Queuing request: ${err.requestOptions.path}');
        }
        _addRequestToQueue(err, handler);
        return;
      }

      _isRefreshing = true;
      if (kDebugMode) {
        print('[AuthInterceptor-onError] Access token expired (received 401). Path: ${err.requestOptions.path}. Attempting to refresh...');
      }

      final localDataSource = sl<AuthLocalDataSource>();
      final authRepository = sl<AuthRepository>();
      
      final oldAuthResult = await localDataSource.getLastAuthResult();
      if (oldAuthResult?.refreshToken == null || oldAuthResult!.refreshToken.isEmpty) {
        if (kDebugMode) {
          print('[AuthInterceptor-onError] No valid refresh token found. Logging out.');
        }
        await authRepository.logout();
        _isRefreshing = false;
        _clearQueueAndReject(err, handler); // Отклоняем текущий и все ожидающие запросы
        return;
      }

      try {
        final newAuthResult = await authRepository.refreshToken(oldAuthResult.refreshToken);
        if (kDebugMode) {
          print('[AuthInterceptor-onError] Token refreshed successfully after 401. New expiration: ${newAuthResult.accessTokenExpiration}');
        }
        
        _isRefreshing = false; // Сбрасываем флаг до обработки очереди и повторного запроса
        _processQueue(newAuthResult.accessToken);

        final newOptions = err.requestOptions;
        newOptions.headers['Authorization'] = 'Bearer ${newAuthResult.accessToken}';
        
        final response = await _dio.fetch(newOptions);
        handler.resolve(response);
        return;

      } catch (e) {
        if (kDebugMode) {
          print('[AuthInterceptor-onError] Token refresh failed during 401 handling: $e. Logging out.');
        }
        await authRepository.logout();
        _isRefreshing = false;
        // Отклоняем текущий запрос и все запросы в очереди той же ошибкой, что вызвала logout
        final errorForRejection = e is DioException ? e : err;
        _clearQueueAndReject(errorForRejection, handler);
        return;
      }
    }
    return handler.next(err);
  }

  void _addRequestToQueue(DioException originalError, ErrorInterceptorHandler originalHandler) {
    _requestQueue.add((newAccessToken) async {
      final newOptions = originalError.requestOptions;
      newOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        if (kDebugMode) {
          print('[AuthInterceptor] Retrying queued request: ${newOptions.path}');
        }
        final response = await _dio.fetch(newOptions);
        originalHandler.resolve(response);
      } catch (e) {
        if (kDebugMode) {
          print('[AuthInterceptor] Queued request failed after retry: $e. Path: ${newOptions.path}');
        }
        // Если запрос из очереди не удался даже с новым токеном, отклоняем его собственной ошибкой
        originalHandler.reject(e is DioException ? e : DioException(requestOptions: newOptions, error: e));
      }
    });
  }

  void _processQueue(String newAccessToken) {
    if (kDebugMode && _requestQueue.isNotEmpty) {
        print('[AuthInterceptor] Processing queue with new access token. Queue size: ${_requestQueue.length}');
    }
    for (var callback in _requestQueue) {
      callback(newAccessToken);
    }
    _requestQueue.clear();
  }

  // Новая функция для очистки очереди и отклонения текущего запроса
  void _clearQueueAndReject(DioException errorToRejectWith, ErrorInterceptorHandler currentHandler) {
    if (kDebugMode && _requestQueue.isNotEmpty) {
        print('[AuthInterceptor] Clearing queue and rejecting pending requests due to error: ${errorToRejectWith.message}');
    }
    // Для запросов в очереди, у нас нет их `ErrorInterceptorHandler` здесь.
    // Поэтому мы просто очищаем очередь. Вызов logout должен привести к навигации, 
    // и эти запросы, если они "повиснут", не должны сильно мешать.
    // Более сложная обработка потребовала бы хранить handler для каждого запроса в очереди.
    _requestQueue.clear();
    currentHandler.reject(errorToRejectWith); // Отклоняем текущий запрос
  }
} 