import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:sigmail_client/domain/repositories/profile_repository.dart';
import 'package:sigmail_client/core/error/failures.dart'; // Исправленный путь
import 'package:dartz/dartz.dart'; // Для Either
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart'; // Импорт AuthBloc
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart'; // Импорт AuthEvent

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository _profileRepository;
  final AuthBloc _authBloc;

  ProfileBloc({required IProfileRepository profileRepository, required AuthBloc authBloc})
      : _profileRepository = profileRepository,
        _authBloc = authBloc,
        super(const ProfileState.initial()) {
    on<AvatarUpdateRequested>(_onAvatarUpdateRequested);
  }

  Future<void> _onAvatarUpdateRequested(
    AvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    final result = await _profileRepository.updateAvatar(event.imageFile);
    result.fold(
      (failure) {
        emit(ProfileState.updateFailure(error: _mapFailureToMessage(failure)));
      },
      (updatedUser) {
        emit(ProfileState.updateSuccess(updatedUser: updatedUser));
        _authBloc.add(UserUpdated(updatedUser: updatedUser)); // Используем прямое имя класса
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Ошибка кэширования';
    } else if (failure is NetworkFailure) {
      return 'Ошибка сети. Проверьте подключение к интернету.';
    }
    return 'Неизвестная ошибка при обновлении профиля';
  }
} 