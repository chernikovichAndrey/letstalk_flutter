part of 'call_bloc.dart';

abstract class CallState {}

class CallInitial extends CallState {}

class CallIncoming extends CallState {
  final int callId;
  final int callerId;
  final String offer;
  final String callType;

  CallIncoming({
    required this.callId,
    required this.callerId,
    required this.offer,
    required this.callType,
  });
}

class CallOutgoing extends CallState {
  final int targetUserId;
  final bool isVideo;

  CallOutgoing({
    required this.targetUserId,
    required this.isVideo,
  });
}

class CallActive extends CallState {
  final int callId;
  final int targetUserId;
  final bool isCaller;
  final bool isVideo;

  CallActive({
    required this.callId,
    required this.targetUserId,
    required this.isCaller,
    required this.isVideo,
  });
}

class CallEnded extends CallState {}

class CallFailure extends CallState {
  final String reason;

  CallFailure(this.reason);
}
