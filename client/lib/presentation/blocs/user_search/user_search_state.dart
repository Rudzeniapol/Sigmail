part of 'user_search_bloc.dart';

sealed class UserSearchState extends Equatable {
  const UserSearchState();

  @override
  List<Object> get props => [];
}

final class UserSearchInitial extends UserSearchState {}

final class UserSearchLoading extends UserSearchState {}

final class UserSearchLoaded extends UserSearchState {
  final List<UserSimpleModel> users;

  const UserSearchLoaded(this.users);

  @override
  List<Object> get props => [users];
}

final class UserSearchError extends UserSearchState {
  final String message;

  const UserSearchError(this.message);

  @override
  List<Object> get props => [message];
} 