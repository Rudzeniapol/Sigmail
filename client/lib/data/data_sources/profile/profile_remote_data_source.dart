import 'dart:io';
import 'package:sigmail_client/data/models/user/user_model.dart';

abstract class IProfileRemoteDataSource {
  Future<UserModel> updateAvatar(File imageFile);
  // Future<UserModel> updateBio(String newBio);
} 