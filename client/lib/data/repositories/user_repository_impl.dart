import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failures.dart';
// import 'package:sigmail_client/data/data_sources/remote/user_remote_data_source.dart'; // УДАЛЯЕМ ИМПОРТ
import 'package:sigmail_client/data/data_sources/realtime/user_realtime_data_source.dart'; 
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  // final UserRemoteDataSource remoteDataSource; // УДАЛЯЕМ ПОЛЕ
  final UserRealtimeDataSource realtimeDataSource;

  UserRepositoryImpl({
    // required this.remoteDataSource, // УДАЛЯЕМ ПАРАМЕТР
    required this.realtimeDataSource,
  });

  // Пример реализации другого метода, если он был бы в интерфейсе
  // @override
  // Future<Either<Failure, UserModel>> getUserById(String id) async {
  //   try {
  //     final userModel = await remoteDataSource.getUserById(id);
  //     return Right(userModel);
  //   } catch (e) {
  //     // Обработка ошибок (например, NetworkFailure, ServerFailure)
  //     return Left(ServerFailure('Failed to get user: $e'));
  //   }
  // }

  @override
  Stream<UserModel> observeUserStatus() {
    // Делегируем вызов соответствующему источнику данных
    return realtimeDataSource.observeUserStatus();
  }
  
  // Реализации других методов из UserRepository...
} 