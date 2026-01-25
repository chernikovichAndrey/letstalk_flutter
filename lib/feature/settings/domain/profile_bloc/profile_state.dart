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
  final String? editingFirstName;
  final String? editingLastName;
  final DateTime? editingBirthday;
  final bool isBirthdayPickerExpanded;

  ProfileLoaded(
    this.user, {
    this.editingFirstName,
    this.editingLastName,
    this.editingBirthday,
    this.isBirthdayPickerExpanded = false,
  });

  ProfileLoaded copyWith({
    UserModel? user,
    String? editingFirstName,
    String? editingLastName,
    DateTime? editingBirthday,
    bool? isBirthdayPickerExpanded,
    bool clearBirthday = false,
  }) {
    return ProfileLoaded(
      user ?? this.user,
      editingFirstName: editingFirstName ?? this.editingFirstName,
      editingLastName: editingLastName ?? this.editingLastName,
      editingBirthday: clearBirthday ? null : (editingBirthday ?? this.editingBirthday),
      isBirthdayPickerExpanded: isBirthdayPickerExpanded ?? this.isBirthdayPickerExpanded,
    );
  }
}

final class ProfileSaving extends ProfileState {
  final UserModel user;

  ProfileSaving(this.user);
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
