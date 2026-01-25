import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/repository/profile_repository.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@singleton
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  int _retryCount = 0;

  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<ProfileLoadEvent>(_onProfileLoad);
    on<ProfileUpdateAvatarEvent>(_onProfileUpdateAvatar);
    on<ProfileUpdateFirstNameEvent>(_onProfileUpdateFirstName);
    on<ProfileUpdateLastNameEvent>(_onProfileUpdateLastName);
    on<ProfileUpdateBirthdayEvent>(_onProfileUpdateBirthday);
    on<ProfileToggleBirthdayPickerEvent>(_onToggleBirthdayPicker);
    on<ProfileSaveChangesEvent>(_onSaveChanges);
  }

  Future<void> _onProfileLoad(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _profileRepository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      if (_retryCount < 5) {
        add(ProfileLoadEvent());
        _retryCount++;
      }
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileUpdateAvatar(
    ProfileUpdateAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(AvatarUploadLoading(currentState.user));
    try {
      await _profileRepository.updateAvatar(event.avatarPath);
      final user = await _profileRepository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(currentState);
    }
  }

  void _onProfileUpdateFirstName(
    ProfileUpdateFirstNameEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(currentState.copyWith(editingFirstName: event.firstName));
  }

  void _onProfileUpdateLastName(
    ProfileUpdateLastNameEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(currentState.copyWith(editingLastName: event.lastName));
  }

  void _onProfileUpdateBirthday(
    ProfileUpdateBirthdayEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(currentState.copyWith(
      editingBirthday: event.birthday,
      clearBirthday: event.birthday == null,
    ));
  }

  void _onToggleBirthdayPicker(
    ProfileToggleBirthdayPickerEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(currentState.copyWith(
      isBirthdayPickerExpanded: !currentState.isBirthdayPickerExpanded,
    ));
  }

  Future<void> _onSaveChanges(
    ProfileSaveChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    
    emit(ProfileSaving(currentState.user));
    try {
      String? birthday;
      if (currentState.editingBirthday != null) {
        birthday = '${currentState.editingBirthday!.year}-'
            '${currentState.editingBirthday!.month.toString().padLeft(2, '0')}-'
            '${currentState.editingBirthday!.day.toString().padLeft(2, '0')}';
      }
      
      final updatedUser = await _profileRepository.updateProfile(
        firstName: currentState.editingFirstName,
        lastName: currentState.editingLastName,
        birthday: birthday,
      );
      
      emit(ProfileLoaded(updatedUser));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(currentState);
    }
  }
}
