import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/auth/create_user_model.dart';
import 'package:sigmail_client/data/models/auth/auth_result_model.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
// TODO: import 'package:sigmail_client/core/use_case/use_case.dart';

class RegisterUserUseCase /* extends UseCase<AuthResultModel, CreateUserModel> */ {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  // @override
  Future<AuthResultModel> call(CreateUserModel createUserModel) async {
    // Теперь CreateUserModel передается напрямую
    return repository.register(createUserModel);
  }
}

// Класс RegisterUserParams больше не нужен здесь, его можно удалить,
// если он не используется где-то еще. Пока оставим закомментированным,
// на случай если он используется в UI для сбора данных формы.
/*
class RegisterUserParams extends Equatable {
  final String email;
  final String username;
  final String password;

  const RegisterUserParams({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}
*/ 