import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failures.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart';

abstract class UserRepository {
  // Пример существующего метода, если он есть (может отличаться)
  // Future<Either<Failure, UserModel>> getUserById(String id);

  // Метод для подписки на обновления статуса пользователя
  Stream<UserModel> observeUserStatus();

  Future<Either<Failure, List<UserSimpleModel>>> searchUsers(String searchTerm);

  // Другие методы, если нужны, например:
  // Future<Either<Failure, void>> updateUserProfile(UserModel user);
} 