part of 'calls_bloc.dart';

@immutable
sealed class CallsEvent {}

class LoadCalls extends CallsEvent {}

class RefreshCalls extends CallsEvent {
  final Completer? completer;

  RefreshCalls({this.completer});
}

class DeleteCall extends CallsEvent {
  final int callId;

  DeleteCall(this.callId);
}
