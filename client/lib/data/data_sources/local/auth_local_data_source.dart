import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';

// Ключи для SharedPreferences
const String _cachedAuthResultKey = 'CACHED_AUTH_RESULT';
const String _cachedUserKey = 'CACHED_USER';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResult(AuthResultModel authResult);
  Future<AuthResultModel?> getLastAuthResult();
  Future<void> clearAuthCache();

  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<void> cacheAuthResult(AuthResultModel authResult) async {
    await _sharedPreferences.setString(
      _cachedAuthResultKey,
      json.encode(authResult.toJson()), // AuthResultModel должен иметь toJson()
    );
    // Также кэшируем пользователя из AuthResultModel
    await cacheUser(authResult.user);
  }

  @override
  Future<AuthResultModel?> getLastAuthResult() async {
    final jsonString = _sharedPreferences.getString(_cachedAuthResultKey);
    if (jsonString != null) {
      try {
        return AuthResultModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
      } catch (e) {
        // Если ошибка декодирования, лучше очистить некорректные данные
        await clearAuthCache();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _sharedPreferences.setString(
      _cachedUserKey,
      json.encode(user.toJson()), // UserModel должен иметь toJson()
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = _sharedPreferences.getString(_cachedUserKey);
    if (jsonString != null) {
      try {
      return UserModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
      } catch (e) {
        await _sharedPreferences.remove(_cachedUserKey);
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearAuthCache() async {
    await _sharedPreferences.remove(_cachedAuthResultKey);
    await _sharedPreferences.remove(_cachedUserKey);
  }
} 