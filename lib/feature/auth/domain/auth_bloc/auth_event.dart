part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String countryCode;
  final String phoneNumber;

  AuthLogin({required this.countryCode, required this.phoneNumber});
}

class AuthLogout extends AuthEvent {}
