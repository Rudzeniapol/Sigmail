import 'dart:async';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
// TODO: import 'package:sigmail_client/core/use_case/use_case.dart'; // Для NoParams

class ObserveAuthChangesUseCase /* extends UseCase<Stream<UserModel?>, NoParams> */ {
  final AuthRepository _repository;

  ObserveAuthChangesUseCase(this._repository);

  // @override
  Stream<UserModel?> call(/* NoParams params */) {
    return _repository.authStateChanges;
  }
} 