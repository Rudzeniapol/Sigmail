import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
// TODO: import 'package:sigmail_client/core/use_case/use_case.dart'; // Для NoParams

class GetCurrentUserUseCase /* extends UseCase<UserModel?, NoParams> */ {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  // @override
  Future<UserModel?> call(/* NoParams params */) async {
    return _repository.getCurrentUser();
  }
} 