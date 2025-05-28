import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/exceptions.dart';
import 'package:sigmail_client/core/error/failures.dart';
import 'package:sigmail_client/data/data_sources/remote/user_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/realtime/user_realtime_data_source.dart'; 
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart';
import 'package:sigmail_client/domain/repositories/user_repository.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserRealtimeDataSource realtimeDataSource;
  final AuthLocalDataSource authLocalDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.realtimeDataSource,
    required this.authLocalDataSource,
  });

  @override
  Stream<UserModel> observeUserStatus() {
    return realtimeDataSource.userStatusStream;
  }
  
  @override
  Future<Either<Failure, List<UserSimpleModel>>> searchUsers(String searchTerm) async {
    try {
      final userModels = await remoteDataSource.searchUsers(searchTerm);
      return Right(userModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown server error'));
    } catch (e) {
      return Left(ServerFailure('Unknown error during user search: ${e.toString()}'));
    }
  }
} 