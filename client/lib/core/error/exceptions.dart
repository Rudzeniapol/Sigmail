class ServerException implements Exception {
  final String? message;
  final int? statusCode;

  ServerException({this.message, this.statusCode});

  @override
  String toString() {
    String output = 'ServerException';
    if (statusCode != null) {
      output += '(statusCode: $statusCode)';
    }
    if (message != null) {
      output += ': $message';
    }
    return output;
  }
}

class CacheException implements Exception {
  final String? message;
  CacheException({this.message});

  @override
  String toString() {
    return 'CacheException(message: $message)';
  }
}

class NetworkException implements Exception {
  final String? message;
  NetworkException({this.message});

  @override
  String toString() {
    return 'NetworkException(message: $message)';
  }
}

class MinioException implements Exception {
  final String? message;
  MinioException({this.message});

  @override
  String toString() {
    return 'MinioException(message: $message)';
  }
} 