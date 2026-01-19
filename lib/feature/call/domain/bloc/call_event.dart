part of 'call_bloc.dart';

abstract class CallEvent {}

class CallInitiated extends CallEvent {
  final int targetUserId;
  final bool isVideo;

  CallInitiated({required this.targetUserId, this.isVideo = false});
}

class CallOfferedReceived extends CallEvent {
  final int callId;
  final String status;

  CallOfferedReceived({
    required this.callId,
    required this.status,
  });
}

class CallIncomingReceived extends CallEvent {
  final int callId;
  final int callerId;
  final String offer;
  final String callType;

  CallIncomingReceived({
    required this.callId,
    required this.callerId,
    required this.offer,
    required this.callType,
  });
}

class CallAccepted extends CallEvent {
  final int callId;
  final int callerId;
  final String offer;
  final bool isVideo;

  CallAccepted({
    required this.callId,
    required this.callerId,
    required this.offer,
    this.isVideo = false,
  });
}

class CallRejected extends CallEvent {
  final int callId;

  CallRejected({required this.callId});
}

class CallHangup extends CallEvent {
  final int callId;

  CallHangup({required this.callId});
}

class CallSignalingReceived extends CallEvent {
  final Map<String, dynamic> data;

  CallSignalingReceived(this.data);
}
