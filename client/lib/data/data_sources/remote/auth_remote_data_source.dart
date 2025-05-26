import 'package:dio/dio.dart';
import 'package:sigmail_client/core/error/exceptions.dart';
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/data/models/auth/create_user_model.dart';
import 'package:sigmail_client/data/models/auth/login_model.dart';
import 'package:sigmail_client/data/models/auth/refresh_token_request_model.dart';

// TODO: Вынести базовый URL в константы или конфигурацию
// const String _baseUrl = 'http://localhost:5000/api'; // Пример, замените на ваш реальный URL

// Базовый URL для эндпоинтов аутентификации, предполагая, что основной URL API уже в Dio
const String _authBaseUrl = '/auth'; // Базовый путь для аутентификации

abstract class AuthRemoteDataSource {
  Future<AuthResultModel> login(LoginModel loginModel);
  Future<AuthResultModel> register(CreateUserModel createUserModel);
  Future<AuthResultModel> refreshToken(RefreshTokenRequestModel refreshTokenRequestModel);
  // Future<void> logout(); // Logout может быть просто удалением токенов на клиенте
  // Future<AuthResultModel> refreshToken(String refreshToken); // Если есть эндпоинт для обновления токена
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResultModel> login(LoginModel loginModel) async {
    try {
      // print('[AuthRemoteDataSourceImpl] Dio baseUrl before LOGIN request: ${_dio.options.baseUrl}'); // ВРЕМЕННЫЙ ЛОГ
      final response = await _dio.post(
        '$_authBaseUrl/login',
        data: loginModel.toJson(), // Убедитесь, что у LoginModel есть toJson()
      );
      if (response.statusCode == 200 && response.data != null) {
        return AuthResultModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        // Обработка ошибок, например, если сервер вернул не 200 или data is null
        // Можно выбросить кастомное исключение
        throw ServerException(message: 'Login failed: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сетевые проблемы, таймауты и т.д.)
      throw ServerException(message: e.message ?? 'Dio error during login', statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(message: 'Unknown error during login: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultModel> register(CreateUserModel createUserModel) async {
    try {
      // print('[AuthRemoteDataSourceImpl] Dio baseUrl before REGISTER request: ${_dio.options.baseUrl}'); // ВРЕМЕННЫЙ ЛОГ
      final response = await _dio.post(
        '$_authBaseUrl/register',
        data: createUserModel.toJson(), // Используем createUserModel
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          return AuthResultModel.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw ServerException(message: 'Registration response data is null', statusCode: response.statusCode);
        }
      } else {
        throw ServerException(message: 'Registration failed with status code: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      print('DioException in register: ${e.message}');
      print('DioException type: ${e.type}');
      if (e.response != null) {
        print('DioException response data: ${e.response?.data}');
        print('DioException response status: ${e.response?.statusCode}');
      }
      throw ServerException(message: e.message ?? 'Dio error during registration', statusCode: e.response?.statusCode);
    } catch (e) {
      print('Unknown error in register: ${e.toString()}');
      throw ServerException(message: 'Unknown error during registration: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultModel> refreshToken(RefreshTokenRequestModel refreshTokenRequestModel) async {
    try {
      final response = await _dio.post(
        '$_authBaseUrl/refresh-token', // Исправленный эндпоинт
        data: refreshTokenRequestModel.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return AuthResultModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Refresh token failed: ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Dio error during refresh token', statusCode: e.response?.statusCode);
    } catch (e) {
      throw ServerException(message: 'Unknown error during refresh token: ${e.toString()}');
    }
  }
}

// Простое кастомное исключение для серверных ошибок
// Можно вынести в core/error/exceptions.dart
// class ServerException implements Exception {  // <--- УДАЛЕНО
//   final String message;
//   final DioException? dioException;
//   ServerException({required this.message, this.dioException});
// 
//   @override
//   String toString() => message;
// } 