part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileLoadEvent extends ProfileEvent {}

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

class ProfileUpdateBirthdayEvent extends ProfileEvent {
  final DateTime? birthday;
  
  ProfileUpdateBirthdayEvent(this.birthday);
}

class ProfileToggleBirthdayPickerEvent extends ProfileEvent {}

class ProfileSaveChangesEvent extends ProfileEvent {}
