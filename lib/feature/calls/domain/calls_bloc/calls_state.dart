part of 'calls_bloc.dart';

@immutable
sealed class CallsState {}

final class CallsInitial extends CallsState {}

final class CallsLoading extends CallsState {}

final class CallsLoaded extends CallsState {
  final List<Call> calls;

  CallsLoaded(this.calls);
}

final class CallsError extends CallsState {
  final String message;

  CallsError(this.message);
}
