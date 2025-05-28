part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.avatarUpdateRequested({required File imageFile}) = AvatarUpdateRequested;
  // Можно будет добавить другие события, например:
  // const factory ProfileEvent.bioUpdateRequested({required String newBio}) = BioUpdateRequested;
} 