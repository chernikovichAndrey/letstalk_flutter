part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileLoadEvent extends ProfileEvent {}

class ResetProfileBloc extends ProfileEvent {}

class ProfileUpdateAvatarEvent extends ProfileEvent {
  final String avatarPath;
  
  ProfileUpdateAvatarEvent(this.avatarPath);
}

class ProfileUpdateFirstNameEvent extends ProfileEvent {
  final String firstName;
  
  ProfileUpdateFirstNameEvent(this.firstName);
}

class ProfileUpdateLastNameEvent extends ProfileEvent {
  final String lastName;
  
  ProfileUpdateLastNameEvent(this.lastName);
}

class ProfileSaveChangesEvent extends ProfileEvent {}

class ProfileRequestDeleteAccountCodeEvent extends ProfileEvent {}

class ProfileDeleteAccountEvent extends ProfileEvent {
  final String confirmCode;
  
  ProfileDeleteAccountEvent(this.confirmCode);
}
