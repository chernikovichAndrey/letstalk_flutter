part of 'call_bloc.dart';

abstract class CallEvent {}

class ResetCallBloc extends CallEvent {}

class CallInitiated extends CallEvent {
  final String? fullName;
  final String? avatar;
  final int targetUserId;
  final bool isVideo;

  CallInitiated({
    required this.targetUserId,
    required this.fullName,
    required this.avatar,
    this.isVideo = false,
  });
}

class CallOfferedReceived extends CallEvent {
  final CallOfferedSignal signal;

  CallOfferedReceived({required this.signal});
}

class CallIncomingReceived extends CallEvent {
  final CallIncomingSignal signal;

  CallIncomingReceived({required this.signal});
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
