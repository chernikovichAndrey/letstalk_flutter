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
    
    emit(ProfileLoading());
    try {
      // TODO: Implement avatar upload to server
      // await _profileRepository.updateAvatar(event.avatarPath);
      
      // For now, just reload the profile
      final user = await _profileRepository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
      // Restore previous state on error
      emit(currentState);
    }
  }
}
