import 'package:dio/dio.dart';
import 'package:sigmail_client/core/network/auth_interceptor.dart';
import 'package:sigmail_client/core/injection_container.dart';

class DioClient {
  final String baseUrl;
  final Dio _dio;
  final AuthInterceptor _authInterceptor;

  DioClient(this.baseUrl, this._authInterceptor) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.interceptors.add(_authInterceptor);
    // Можно добавить LogInterceptor для отладки
    // _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;
} 