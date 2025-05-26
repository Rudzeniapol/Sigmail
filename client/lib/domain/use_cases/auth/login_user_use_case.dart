import 'package:sigmail_client/data/models/auth/login_model.dart';
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
// TODO: import 'package:sigmail_client/core/use_case/use_case.dart'; // Для базового класса UseCase, если есть

class LoginUserUseCase /* extends UseCase<AuthResultModel, LoginModel> */ {
  final AuthRepository _repository;

  LoginUserUseCase(this._repository);

  // @override
  Future<AuthResultModel> call(LoginModel params) async {
    // TODO: Можно добавить обработку ошибок или возвращать Result тип
    return _repository.login(params);
  }
} 