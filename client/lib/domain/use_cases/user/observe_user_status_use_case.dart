import 'dart:async';

import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/user_repository.dart';

// Событие, которое мы ожидаем от SignalR, может быть просто UserModel
// или специальная модель UserStatusUpdate, если сервер шлет только ID, isOnline, lastSeen.
// Для простоты пока будем считать, что сервер шлет UserModel целиком при обновлении статуса.

class ObserveUserStatusUseCase implements StreamUseCase<UserModel, NoParams> {
  final UserRepository _repository;

  ObserveUserStatusUseCase(this._repository);

  @override
  Stream<UserModel> call(NoParams params) {
    return _repository.observeUserStatus();
  }
} 