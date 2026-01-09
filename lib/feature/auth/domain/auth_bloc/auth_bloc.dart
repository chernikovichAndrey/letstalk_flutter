import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final dynamic authRepository; // Keep dynamic or proper type if known
  
  AuthBloc(this.authRepository) : super(AuthUnauthenticated()) {
    on<AuthLogin>((event, emit) {
      emit(AuthAuthenticated());
    });
    on<AuthLogout>((event, emit) {
      emit(AuthUnauthenticated());
    });
  }
}
