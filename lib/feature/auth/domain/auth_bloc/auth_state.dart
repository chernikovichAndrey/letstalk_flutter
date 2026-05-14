part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthUnauthenticated extends AuthState {}

final class AuthCodeSent extends AuthState {
  final String countryCode;
  final String phoneNumber;

  String get phone => '$countryCode$phoneNumber';

  AuthCodeSent({
    required this.countryCode,
    required this.phoneNumber,
  });
}

final class AuthProfileSetupRequired extends AuthState {
  final String token;

  AuthProfileSetupRequired({required this.token});
}

final class AuthAuthenticated extends AuthState {
  final String? token;
  AuthAuthenticated({this.token});
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
