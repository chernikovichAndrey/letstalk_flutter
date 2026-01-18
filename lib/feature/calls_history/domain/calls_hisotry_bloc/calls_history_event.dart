part of 'calls_history_bloc.dart';

@immutable
sealed class CallsHistoryEvent {}

class LoadHistoryCalls extends CallsHistoryEvent {}

class RefreshHistoryCalls extends CallsHistoryEvent {
  final Completer? completer;

  RefreshHistoryCalls({this.completer});
}

class DeleteHistoryCall extends CallsHistoryEvent {
  final int callId;

  DeleteHistoryCall(this.callId);
}
