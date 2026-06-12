import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/service/callkit_service.dart';
import 'package:lets_talk/common/service/push_notification_service.dart';
import 'package:lets_talk/common/service/reset_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final PushNotificationService pushNotificationService;
  final CallKitService callKitService;

  AuthBloc(this.authRepository, this.pushNotificationService, this.callKitService)
    : super(AuthInitial()) {
    on<AuthCheckStatus>((event, emit) async {
      try {
        final token = await authRepository.getToken();
        if (token != null) {
          emit(AuthAuthenticated(token: token));
          await _onSendToken();
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      } finally {
        FlutterNativeSplash.remove();
      }
    });

    on<AuthSendCode>((event, emit) async {
      try {
        await authRepository.sendPhone(event.countryCode, event.phoneNumber);
        emit(
          AuthCodeSent(
            countryCode: event.countryCode,
            phoneNumber: event.phoneNumber,
          ),
        );
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthUnauthenticated());
      }
    });

    on<AuthVerifyCode>((event, emit) async {
      final currentState = state;
      if (currentState is AuthCodeSent) {
        try {
          final result = await authRepository.verifyCode(
            currentState.phone,
            event.code,
          );
          if (result.isNewUser) {
            emit(AuthProfileSetupRequired(token: result.token));
          } else {
            emit(AuthAuthenticated(token: result.token));
            await _onSendToken();
          }
        } catch (e) {
          if ((e as DioException).response?.statusCode == 422) {
            emit(AuthInvalidCode());
          } else {
            emit(AuthError(e.toString()));
          }
          emit(currentState);
        }
      }
    });

    on<AuthCompleteProfileSetup>((event, emit) async {
      final currentState = state;
      if (currentState is AuthProfileSetupRequired) {
        try {
          await authRepository.updateProfile(
            firstName: event.firstName,
            lastName: event.lastName,
          );
          emit(AuthAuthenticated(token: currentState.token));
          await _onSendToken();
        } catch (e) {
          emit(AuthError(e.toString()));
          emit(currentState);
        }
      }
    });

    on<AuthLogout>((event, emit) async {
      await pushNotificationService.unregisterFromServer();
      if (Platform.isIOS) {
        await callKitService.unregisterFromServer();
      }
      await pushNotificationService.deleteToken();
      await authRepository.deleteToken();
      getIt<ResetService>().resetAll();
      emit(AuthUnauthenticated());
    });
  }

  Future<void> _onSendToken() async {
    // Send FCM token after successful login
    final fcmToken = pushNotificationService.fcmToken;
    if (fcmToken != null) {
      final platform = Platform.isIOS ? 'iOS' : 'Android';
      try {
        await authRepository.updateFcmToken(fcmToken, platform);
      } catch (e) {
        debugPrint('Failed to update FCM token: $e');
      }
    }
  }
}
