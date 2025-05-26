part of 'user_status_bloc.dart';

abstract class UserStatusEvent extends Equatable {
  const UserStatusEvent();

  @override
  List<Object> get props => [];
}

// Событие для начала наблюдения за статусами
class ObserveUserStatusesStarted extends UserStatusEvent {}

// Внутреннее событие, когда приходит обновление статуса от use case
class _UserStatusUpdated extends UserStatusEvent {
  final UserModel userWithNewStatus;

  const _UserStatusUpdated(this.userWithNewStatus);

  @override
  List<Object> get props => [userWithNewStatus];
}

// Событие для остановки наблюдения (если необходимо)
// class ObserveUserStatusesStopped extends UserStatusEvent {} 