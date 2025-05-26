import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/auth/create_user_model.dart';
import 'package:sigmail_client/data/models/auth/login_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Событие, чтобы проверить начальный статус аутентификации
class AuthCheckRequested extends AuthEvent {}

// Событие при изменении состояния аутентификации (например, из Stream)
class AuthStateChanged extends AuthEvent {
  final dynamic user; // UserModel? или null
  const AuthStateChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class LoginRequested extends AuthEvent {
  final LoginModel loginModel;

  const LoginRequested(this.loginModel);

  @override
  List<Object?> get props => [loginModel];
}

class RegisterRequested extends AuthEvent {
  final CreateUserModel createUserModel;

  const RegisterRequested(this.createUserModel);

  @override
  List<Object?> get props => [createUserModel];
}

class LogoutRequested extends AuthEvent {} 