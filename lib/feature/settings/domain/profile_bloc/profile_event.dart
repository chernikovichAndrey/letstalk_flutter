part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileLoadEvent extends ProfileEvent {}

class ProfileUpdateAvatarEvent extends ProfileEvent {
  final String avatarPath;
  
  ProfileUpdateAvatarEvent(this.avatarPath);
}
