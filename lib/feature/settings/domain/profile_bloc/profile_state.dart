part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class AvatarUploadLoading extends ProfileState {
  final UserModel user;

  AvatarUploadLoading(this.user);
}

final class ProfileLoaded extends ProfileState {
  final UserModel user;

  ProfileLoaded(this.user);
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
