import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/data/models/auth/create_user_model.dart';
import 'package:sigmail_client/data/models/auth/login_model.dart';
import 'package:sigmail_client/data/models/user/user_model.dart'; // Или ваша доменная сущность пользователя

// Абстрактный класс (интерфейс) для репозитория аутентификации
abstract class AuthRepository {
  // Поток для отслеживания текущего статуса аутентификации / пользователя
  // Может возвращать UserModel? (nullable) или специальный AuthStatus enum
  Stream<UserModel?> get authStateChanges;

  Future<AuthResultModel> login(LoginModel loginModel);

  Future<AuthResultModel> register(CreateUserModel createUserModel);

  Future<void> logout();

  // Получение текущего пользователя, если он аутентифицирован
  // Может быть синхронным, если статус пользователя уже известен из потока authStateChanges
  // или если вы храните пользователя в сессии/локально
  Future<UserModel?> getCurrentUser();

  // Метод для обновления токена
  Future<AuthResultModel> refreshToken(String refreshTokenValue);
} 