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

  ProfileBloc(this._profileRepository) : super(ProfileState.initial()) {
    on<ResetProfileBloc>(_onResetProfileBloc);
    on<ProfileLoadEvent>(_onProfileLoad);
    on<ProfileUpdateAvatarEvent>(_onProfileUpdateAvatar);
    on<ProfileUpdateFirstNameEvent>(_onProfileUpdateFirstName);
    on<ProfileUpdateLastNameEvent>(_onProfileUpdateLastName);
    on<ProfileSaveChangesEvent>(_onSaveChanges);
    on<ProfileRequestDeleteAccountCodeEvent>(_onRequestDeleteAccountCode);
    on<ProfileDeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onProfileLoad(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _profileRepository.getProfile();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
      ));
    } catch (e) {
      if (_retryCount < 5) {
        add(ProfileLoadEvent());
        _retryCount++;
      }
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onProfileUpdateAvatar(
    ProfileUpdateAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.status != ProfileStatus.loaded) return;
    
    emit(state.copyWith(status: ProfileStatus.avatarUploadLoading));
    try {
      await _profileRepository.updateAvatar(event.avatarPath);
      final user = await _profileRepository.getProfile();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }

  void _onProfileUpdateFirstName(
    ProfileUpdateFirstNameEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state.status != ProfileStatus.loaded) return;
    
    emit(state.copyWith(editingFirstName: event.firstName));
  }

  void _onProfileUpdateLastName(
    ProfileUpdateLastNameEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state.status != ProfileStatus.loaded) return;
    
    emit(state.copyWith(editingLastName: event.lastName));
  }

  Future<void> _onSaveChanges(
    ProfileSaveChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.status != ProfileStatus.loaded) return;
    
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final updatedUser = await _profileRepository.updateProfile(
        firstName: state.editingFirstName ?? state.user?.firstName,
        lastName: state.editingLastName ?? state.user?.lastName,
      );
      
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
        editingFirstName: null,
        editingLastName: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }

  Future<void> _onRequestDeleteAccountCode(
    ProfileRequestDeleteAccountCodeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;
    
    try {
      await _profileRepository.requestDeleteAccountCode(state.user!.phone);
      emit(state.copyWith(status: ProfileStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }

  Future<void> _onDeleteAccount(
    ProfileDeleteAccountEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.deletingAccount));
    try {
      await _profileRepository.deleteAccount(event.confirmCode);
      emit(state.copyWith(status: ProfileStatus.accountDeleted));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: ProfileStatus.loaded));
    }
  }

  void _onResetProfileBloc(ResetProfileBloc event, Emitter<ProfileState> emit) {
    emit(ProfileState.initial());
  }
}
