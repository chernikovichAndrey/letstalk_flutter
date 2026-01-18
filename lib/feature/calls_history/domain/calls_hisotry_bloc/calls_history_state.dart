part of 'calls_history_bloc.dart';

@immutable
sealed class CallsHistoryState {}

final class CallsHistoryInitial extends CallsHistoryState {}

final class CallsHistoryLoading extends CallsHistoryState {}

final class CallsHistoryLoaded extends CallsHistoryState {
  final List<CallHistory> calls;

  CallsHistoryLoaded(this.calls);
}

final class CallsHistoryError extends CallsHistoryState {
  final String message;

  CallsHistoryError(this.message);
}
