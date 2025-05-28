import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sigmail_client/core/error/failures.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserModel>> updateAvatar(File imageFile);
  // Можно добавить другие методы, например:
  // Future<Either<Failure, UserModel>> updateBio(String newBio);
} 