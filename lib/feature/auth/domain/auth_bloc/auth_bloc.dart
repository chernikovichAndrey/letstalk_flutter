import 'package:bloc/bloc.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc(this.authRepository) : super(AuthUnauthenticated()) {
    on<AuthLogin>((event, emit) async {
      try {
        await authRepository.sendPhone(event.countryCode, event.phoneNumber);
        emit(AuthAuthenticated());
      } catch (e) {
        // In a real app we would emit an error state
        // emit(AuthError(e.toString()));
      }
    });
    on<AuthLogout>((event, emit) {
      emit(AuthUnauthenticated());
    });
  }
}
