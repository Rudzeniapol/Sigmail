part of 'user_status_bloc.dart';


enum UserStatusObservationStatus { initial, loading, success, failure }

class UserStatusState extends Equatable {
  final UserStatusObservationStatus observationStatus;
  // Карта для хранения статусов пользователей: userId -> UserModel (или специальная модель UserStatus)
  final Map<String, UserModel> userStatuses;
  final Failure? error;

  const UserStatusState({
    this.observationStatus = UserStatusObservationStatus.initial,
    this.userStatuses = const {},
    this.error,
  });

  UserStatusState copyWith({
    UserStatusObservationStatus? observationStatus,
    Map<String, UserModel>? userStatuses,
    Failure? error,
    bool NoclearError = false, // Флаг, чтобы не очищать ошибку при копировании
  }) {
    return UserStatusState(
      observationStatus: observationStatus ?? this.observationStatus,
      userStatuses: userStatuses ?? this.userStatuses,
      error: NoclearError ? this.error : error, // Если clearError не установлен или false, то error может быть заменен на null
    );
  }

  @override
  List<Object?> get props => [observationStatus, userStatuses, error];
} 