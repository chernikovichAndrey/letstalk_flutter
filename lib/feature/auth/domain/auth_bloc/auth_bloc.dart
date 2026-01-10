import 'package:bloc/bloc.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthCheckStatus>((event, emit) async {
       try {
         final token = await authRepository.getToken();
         if (token != null) {
           emit(AuthAuthenticated());
         } else {
           emit(AuthUnauthenticated());
         }
       } catch (e) {
         emit(AuthUnauthenticated());
       }
    });

    on<AuthSendCode>((event, emit) async {
      try {
        await authRepository.sendPhone(event.countryCode, event.phoneNumber);
        emit(AuthCodeSent(phone: '${event.countryCode}${event.phoneNumber}'));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthUnauthenticated());
      }
    });

    on<AuthVerifyCode>((event, emit) async {
      final currentState = state;
      if (currentState is AuthCodeSent) {
        try {
          final token = await authRepository.verifyCode(currentState.phone, event.code);
          await authRepository.saveToken(token);
          emit(AuthAuthenticated());
        } catch (e) {
          emit(AuthError(e.toString()));
          emit(currentState);
        }
      }
    });

    on<AuthLogout>((event, emit) async {
      await authRepository.deleteToken();
      emit(AuthUnauthenticated());
    });
  }
}
