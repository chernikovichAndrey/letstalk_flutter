part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthUnauthenticated extends AuthState {}

final class AuthCodeSent extends AuthState {
  final String phone;
  AuthCodeSent({required this.phone});
}

final class AuthAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
