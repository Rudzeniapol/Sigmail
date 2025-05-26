import 'package:sigmail_client/domain/repositories/auth_repository.dart';
// TODO: import 'package:sigmail_client/core/use_case/use_case.dart'; // Для NoParams

class LogoutUserUseCase /* extends UseCase<void, NoParams> */ {
  final AuthRepository _repository;

  LogoutUserUseCase(this._repository);

  // @override
  Future<void> call(/* NoParams params */) async {
    return _repository.logout();
  }
}

// Если у вас нет NoParams, можно просто не передавать параметры или использовать void
// class NoParams {} 