import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/use_cases/auth/get_current_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/login_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/logout_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/observe_auth_changes_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/register_user_use_case.dart';
import './auth_event.dart';
import './auth_state.dart';
import 'package:sigmail_client/core/error/exceptions.dart';

// Импорты для управления UserRealtimeDataSource и UserStatusBloc
import 'package:sigmail_client/core/injection_container.dart';
import 'package:sigmail_client/data/data_sources/realtime/user_realtime_data_source.dart';
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUserUseCase _loginUser;
  final RegisterUserUseCase _registerUser;
  final LogoutUserUseCase _logoutUser;
  final GetCurrentUserUseCase _getCurrentUser;
  final ObserveAuthChangesUseCase _observeAuthChanges;
  StreamSubscription<UserModel?>? _authChangesSubscription;
  StreamSubscription<UserAvatarUpdate>? _userAvatarUpdateSubscription;

  // Зависимости для управления статусами пользователя
  final UserRealtimeDataSource _userRealtimeDataSource;
  final UserStatusBloc _userStatusBloc;

  AuthBloc({
    required LoginUserUseCase loginUser,
    required RegisterUserUseCase registerUser,
    required LogoutUserUseCase logoutUser,
    required GetCurrentUserUseCase getCurrentUser,
    required ObserveAuthChangesUseCase observeAuthChanges,
    // Добавляем UserRealtimeDataSource и UserStatusBloc в конструктор
    required UserRealtimeDataSource userRealtimeDataSource,
    required UserStatusBloc userStatusBloc,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _logoutUser = logoutUser,
        _getCurrentUser = getCurrentUser,
        _observeAuthChanges = observeAuthChanges,
        _userRealtimeDataSource = userRealtimeDataSource, // Инициализируем
        _userStatusBloc = userStatusBloc, // Инициализируем
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserUpdated>(_onUserUpdated);
    on<RealtimeAvatarUpdateReceived>(_onRealtimeAvatarUpdateReceived);

    // Подписываемся на изменения состояния аутентификации
    _authChangesSubscription = _observeAuthChanges.call().listen((user) {
      add(AuthStateChanged(user));
    });

    // Подписываемся на обновления аватара из UserRealtimeDataSource
    _userAvatarUpdateSubscription = _userRealtimeDataSource.userAvatarUpdateStream.listen((avatarUpdate) {
      add(RealtimeAvatarUpdateReceived(userId: avatarUpdate.userId, newAvatarUrl: avatarUpdate.newAvatarUrl));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUser.call();
      if (user != null) {
        // Пользователь аутентифицирован, подключаемся к UserRealtimeDataSource и начинаем наблюдение
        await _userRealtimeDataSource.connect();
        _userStatusBloc.add(ObserveUserStatusesStarted());
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated()); // Если ошибка при проверке, считаем неаутентифицированным
    }
  }
  
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      // Пользователь аутентифицирован
      // Проверяем, нужно ли подключаться (если это не было сделано в _onAuthCheckRequested)
      if (!_userRealtimeDataSource.isConnected) { 
         // Используем await для гарантированного завершения подключения перед следующими шагами
         await _userRealtimeDataSource.connect(); 
         _userStatusBloc.add(ObserveUserStatusesStarted());
      }
      emit(Authenticated(event.user!));
    } else {
      // Пользователь не аутентифицирован, отключаемся, только если было активное соединение
      if (_userRealtimeDataSource.isConnected) { // <--- Добавим проверку isConnected перед disconnect
        await _userRealtimeDataSource.disconnect(); // <--- Добавим await
      }
      // Здесь можно также остановить наблюдение в UserStatusBloc, если это необходимо
      // _userStatusBloc.add(ObserveUserStatusesStopped()); 
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authResult = await _loginUser.call(event.loginModel);
      // Пользователь успешно вошел, подключаемся и начинаем наблюдение
      await _userRealtimeDataSource.connect();
      _userStatusBloc.add(ObserveUserStatusesStarted());
      emit(Authenticated(authResult.user));
    } on ServerException catch (e) {
      emit(AuthFailure(e.message ?? 'Unknown server error'));
    } catch (e) {
      emit(AuthFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authResult = await _registerUser.call(event.createUserModel);
      // Пользователь успешно зарегистрировался и вошел, подключаемся и начинаем наблюдение
      await _userRealtimeDataSource.connect();
      _userStatusBloc.add(ObserveUserStatusesStarted());
      emit(Authenticated(authResult.user));
    } on ServerException catch (e) {
      emit(AuthFailure(e.message ?? 'Unknown server error'));
    } catch (e) {
      emit(AuthFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _logoutUser.call();
      // Пользователь вышел, отключаемся
      await _userRealtimeDataSource.disconnect();
      // Можно остановить наблюдение в UserStatusBloc
      // _userStatusBloc.add(ObserveUserStatusesStopped());
      emit(Unauthenticated());
    } catch (e) {
      // Даже если при выходе ошибка, отключаемся
      await _userRealtimeDataSource.disconnect();
      emit(Unauthenticated()); 
      // emit(AuthFailure('Logout failed: ${e.toString()}'));
    }
  }

  // Обработчик для события UserUpdated
  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    final currentState = state;
    if (currentState is Authenticated) {
      // Обновляем пользователя в текущем Authenticated состоянии
      emit(Authenticated(event.updatedUser));
    } 
    // Если состояние не Authenticated, то ничего не делаем, 
    // так как обновлять нечего или пользователь не вошел в систему.
  }

  // Новый обработчик для события обновления аватара из SignalR
  void _onRealtimeAvatarUpdateReceived(RealtimeAvatarUpdateReceived event, Emitter<AuthState> emit) {
    final currentState = state;
    if (currentState is Authenticated) {
      // Обновляем только если ID пользователя совпадает с текущим аутентифицированным пользователем
      // ИЛИ если мы хотим обновлять аватары других пользователей, видимых в UI (например, в списке чатов)
      // Сейчас предполагаем, что это событие только для ТЕКУЩЕГО пользователя.
      // Если это для любого пользователя, то нужно будет найти и обновить его в каком-то общем списке пользователей.
      if (currentState.user.id == event.userId) {
        final updatedUser = currentState.user.copyWith(profileImageUrl: event.newAvatarUrl);
        emit(Authenticated(updatedUser));
      }
    }
  }

  @override
  Future<void> close() {
    _authChangesSubscription?.cancel();
    _userAvatarUpdateSubscription?.cancel();
    // Отключаемся при закрытии AuthBloc
    _userRealtimeDataSource.disconnect(); 
    return super.close();
  }
} 