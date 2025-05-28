part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.updateSuccess({required UserModel updatedUser}) = _UpdateSuccess;
  const factory ProfileState.updateFailure({required String error}) = _UpdateFailure;
} 