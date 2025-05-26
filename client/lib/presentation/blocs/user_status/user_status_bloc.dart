import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/core/error/failures.dart';
import 'package:sigmail_client/core/use_case.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/use_cases/user/observe_user_status_use_case.dart';

part 'user_status_event.dart';
part 'user_status_state.dart';

class UserStatusBloc extends Bloc<UserStatusEvent, UserStatusState> {
  final ObserveUserStatusUseCase _observeUserStatusUseCase;
  StreamSubscription<UserModel>? _userStatusSubscription;

  // Для UserRealtimeDataSource (подключение/отключение)
  // Это не очень хорошая практика - BLoC не должен напрямую управлять DataSource.
  // Лучше это делать на уровне инициализации приложения или в специальном сервисе.
  // final UserRealtimeDataSource _userRealtimeDataSource;

  UserStatusBloc({
    required ObserveUserStatusUseCase observeUserStatusUseCase,
    // required UserRealtimeDataSource userRealtimeDataSource, // Убрано
  })  : _observeUserStatusUseCase = observeUserStatusUseCase,
        // _userRealtimeDataSource = userRealtimeDataSource, // Убрано
        super(const UserStatusState()) {
    on<ObserveUserStatusesStarted>(_onObserveUserStatusesStarted);
    on<_UserStatusUpdated>(_onUserStatusUpdated);
  }

  Future<void> _onObserveUserStatusesStarted(
    ObserveUserStatusesStarted event,
    Emitter<UserStatusState> emit,
  ) async {
    emit(state.copyWith(observationStatus: UserStatusObservationStatus.loading));
    
    // Перед началом нового наблюдения, отменяем старое, если оно было
    await _userStatusSubscription?.cancel();

    // Управление подключением UserRealtimeDataSource должно быть снаружи этого BLoC.
    // Например, при старте приложения или после логина.
    // await _userRealtimeDataSource.connect(); 

    _userStatusSubscription = _observeUserStatusUseCase.call(NoParams()).listen(
      (userStatus) {
        add(_UserStatusUpdated(userStatus));
      },
      onError: (error) {
        // Можно добавить обработку ошибок стрима, если необходимо
        emit(state.copyWith(
          observationStatus: UserStatusObservationStatus.failure,
          error: ServerFailure('Failed to observe user statuses: $error'),
        ));
      },
      onDone: () {
        // Стрим завершился (может быть неожиданно)
        emit(state.copyWith(observationStatus: UserStatusObservationStatus.success)); // Или failure, в зависимости от логики
      },
    );
    // Сразу переходим в состояние success, т.к. подписка установлена.
    // Ошибки будут обрабатываться в onError.
    emit(state.copyWith(observationStatus: UserStatusObservationStatus.success));
  }

  void _onUserStatusUpdated(
    _UserStatusUpdated event,
    Emitter<UserStatusState> emit,
  ) {
    final updatedStatuses = Map<String, UserModel>.from(state.userStatuses);
    updatedStatuses[event.userWithNewStatus.id] = event.userWithNewStatus;
    emit(state.copyWith(userStatuses: updatedStatuses, observationStatus: UserStatusObservationStatus.success));
  }

  @override
  Future<void> close() {
    _userStatusSubscription?.cancel();
    // Управление отключением UserRealtimeDataSource также должно быть снаружи.
    // await _userRealtimeDataSource.disconnect(); 
    return super.close();
  }
} 