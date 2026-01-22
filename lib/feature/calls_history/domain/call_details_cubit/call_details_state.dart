part of 'call_details_cubit.dart';

sealed class CallDetailsState {}

final class CallDetailsInitial extends CallDetailsState {}

final class CallDetailsLoading extends CallDetailsState {}

final class CallDetailsLoaded extends CallDetailsState {
  final CallHistory call;

  CallDetailsLoaded(this.call);
}

final class CallDetailsError extends CallDetailsState {
  final String message;

  CallDetailsError(this.message);
}
