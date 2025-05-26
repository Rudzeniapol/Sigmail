import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} // Начальное состояние, пока не определено, вошел ли пользователь

class AuthLoading extends AuthState {} // Процесс аутентификации/регистрации/выхода

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {} // Пользователь не аутентифицирован

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
} 