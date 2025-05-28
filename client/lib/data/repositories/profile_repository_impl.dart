import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/exceptions.dart';
import 'package:sigmail_client/core/error/failures.dart';
import 'package:sigmail_client/core/network/network_info.dart';
import 'package:sigmail_client/data/data_sources/profile/profile_remote_data_source.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;
  final INetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserModel>> updateAvatar(File imageFile) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateAvatar(imageFile);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message ?? 'Ошибка сервера при обновлении аватара'));
      } on MinioException catch (e) {
        return Left(ServerFailure(e.message ?? 'Ошибка хранилища при обновлении аватара'));
      } catch (e) {
        return Left(ServerFailure('Неизвестная ошибка при обновлении аватара: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('Отсутствует подключение к сети'));
    }
  }
} 