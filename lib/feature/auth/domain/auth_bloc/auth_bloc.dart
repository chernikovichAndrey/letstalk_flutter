import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/reset_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  
  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthCheckStatus>((event, emit) async {
       try {
         final token = await authRepository.getToken();
         FlutterNativeSplash.remove();
         if (token != null) {
           emit(AuthAuthenticated(token: token));
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
        emit(AuthCodeSent(
          countryCode: event.countryCode,
          phoneNumber: event.phoneNumber,
        ));
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
          emit(AuthAuthenticated(token: token));
        } catch (e) {
          emit(AuthError(e.toString()));
          emit(currentState);
        }
      }
    });

    on<AuthLogout>((event, emit) async {
      await authRepository.deleteToken();
      getIt<ResetService>().resetAll();
      emit(AuthUnauthenticated());
    });
  }
}
