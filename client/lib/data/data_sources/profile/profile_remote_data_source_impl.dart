import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/data/data_sources/profile/profile_remote_data_source.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/core/error/exceptions.dart';
import 'package:http_parser/http_parser.dart'; // Для MediaType

class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  final Dio dio;
  static const String _usersEndpoint = '/users';

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> updateAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Определяем ContentType более надежно
      MediaType? contentType;
      if (['jpg', 'jpeg'].contains(fileExtension)) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileExtension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (fileExtension == 'gif') {
        contentType = MediaType('image', 'gif');
      } // Добавить другие типы при необходимости

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path, 
          filename: fileName,
          contentType: contentType, // Используем определенный MediaType
        ),
      });

      final response = await dio.post(
        '${AppConfig.baseUrl}$_usersEndpoint/me/avatar', 
        data: formData,
         options: Options(
          headers: {
            // 'Content-Type': 'multipart/form-data', // Dio обычно устанавливает это автоматически для FormData
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
            if (response.data.containsKey('user') && response.data['user'] is Map<String, dynamic>){
                 return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
            }
            return UserModel.fromJson(response.data as Map<String, dynamic>);
        }
        throw ServerException(message: 'Ответ сервера не содержит данные пользователя в ожидаемом формате.', statusCode: response.statusCode);
      } else {
        String errorMessage = 'Ошибка сервера при обновлении аватара: ${response.statusMessage}';
        if (response.data != null && response.data is Map) {
           final responseMap = response.data as Map<String, dynamic>;
           if (responseMap.containsKey('message')) {
             errorMessage = responseMap['message'];
           } else if (responseMap.containsKey('detail')) {
             errorMessage = responseMap['detail'];
           }
        } else if (response.data != null && response.data is String) {
          errorMessage = response.data;
        }
        throw ServerException(message: errorMessage, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      String errorMessage = 'Ошибка Dio при обновлении аватара: ${e.message}';
      int? statusCode = e.response?.statusCode;
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          final responseMap = e.response!.data as Map<String, dynamic>;
          if (responseMap.containsKey('message')) {
            errorMessage = responseMap['message'];
          } else if (responseMap.containsKey('detail')) {
            errorMessage = responseMap['detail'];
          }
        } else if (e.response!.data is String) {
            errorMessage = e.response!.data as String;
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.sendTimeout || 
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      }
      throw ServerException(message: errorMessage, statusCode: statusCode);
    } catch (e) {
      throw ServerException(message: 'Неизвестная ошибка при обновлении аватара: ${e.toString()}');
    }
  }
} 