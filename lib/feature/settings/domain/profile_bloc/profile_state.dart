part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  avatarUploadLoading,
  loaded,
  saving,
  error,
  deletingAccount,
  accountDeleted,
}

@immutable
class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final String? editingFirstName;
  final String? editingLastName;
  final String? errorMessage;

  const ProfileState({
    required this.status,
    this.user,
    this.editingFirstName,
    this.editingLastName,
    this.errorMessage,
  });

  factory ProfileState.initial() => const ProfileState(status: ProfileStatus.initial);

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    String? editingFirstName,
    String? editingLastName,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      editingFirstName: editingFirstName ?? this.editingFirstName,
      editingLastName: editingLastName ?? this.editingLastName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
