import 'package:dio/dio.dart';
import 'package:sigmail_client/core/error/exceptions.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart';

const String _usersBaseUrl = '/users'; // Базовый путь для пользователей

abstract class UserRemoteDataSource {
  Future<List<UserSimpleModel>> searchUsers(String searchTerm);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserSimpleModel>> searchUsers(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return []; // Возвращаем пустой список, если поисковый запрос пуст
    }
    try {
      final response = await _dio.get(
        '$_usersBaseUrl/search',
        queryParameters: {'query': searchTerm},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> userListJson = response.data as List<dynamic>;
        return userListJson
            .map((json) => UserSimpleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search users: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Dio error during user search',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Unknown error during user search: ${e.toString()}');
    }
  }
} 