part of 'calls_bloc.dart';

@immutable
sealed class CallsEvent {}

class LoadCalls extends CallsEvent {}

class DeleteCall extends CallsEvent {
  final int callId;

  DeleteCall(this.callId);
}
