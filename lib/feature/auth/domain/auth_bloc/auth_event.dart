part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthSendCode extends AuthEvent {
  final String countryCode;
  final String phoneNumber;

  AuthSendCode({required this.countryCode, required this.phoneNumber});
}

class AuthVerifyCode extends AuthEvent {
  final String code;
  AuthVerifyCode({required this.code});
}

class AuthCompleteProfileSetup extends AuthEvent {
  final String firstName;
  final String? lastName;

  AuthCompleteProfileSetup({required this.firstName, this.lastName});
}

class AuthCheckStatus extends AuthEvent {}

class AuthLogout extends AuthEvent {}
