import 'package:lets_talk/common/model/call_signaling_type.dart';

abstract class SignalingEvent {
  const SignalingEvent();

  factory SignalingEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = CallSignalingType.fromString(typeStr ?? '');

    switch (type) {
      case CallSignalingType.callOffered:
        return CallOfferedSignal.fromJson(json);
      case CallSignalingType.callIncoming:
        return CallIncomingSignal.fromJson(json);
      case CallSignalingType.callAnswered:
        return CallAnsweredSignal.fromJson(json);
      case CallSignalingType.iceCandidate:
        return IceCandidateSignal.fromJson(json);
      case CallSignalingType.callEnded:
        return CallEndedSignal.fromJson(json);
      case CallSignalingType.callRejected:
        return CallRejectedSignal.fromJson(json);
      case CallSignalingType.callFailed:
        return CallFailedSignal.fromJson(json);
      default:
        return UnknownSignal(typeStr, json);
    }
  }
}

class CallOfferedSignal extends SignalingEvent {
  final int callId;
  final String status;

  const CallOfferedSignal({
    required this.callId,
    required this.status,
  });

  factory CallOfferedSignal.fromJson(Map<String, dynamic> json) {
    return CallOfferedSignal(
      callId: int.tryParse(json['call_id'].toString()) ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

class CallIncomingSignal extends SignalingEvent {
  final int callId;
  final int callerId;
  final String offer;
  final String callType;

  const CallIncomingSignal({
    required this.callId,
    required this.callerId,
    required this.offer,
    this.callType = 'audio',
  });

  factory CallIncomingSignal.fromJson(Map<String, dynamic> json) {
    return CallIncomingSignal(
      callId: int.tryParse(json['call_id'].toString()) ?? 0,
      callerId: json['caller_id'] as int? ?? 0,
      offer: json['offer'] as String? ?? '',
      callType: json['call_type'] as String? ?? 'audio',
    );
  }
}

class CallAnsweredSignal extends SignalingEvent {
  final int callId;
  final String answer;

  const CallAnsweredSignal({
    required this.callId,
    required this.answer,
  });

  factory CallAnsweredSignal.fromJson(Map<String, dynamic> json) {
    return CallAnsweredSignal(
      callId: int.tryParse(json['call_id'].toString()) ?? 0,
      answer: json['answer'] as String? ?? '',
    );
  }
}

class IceCandidateSignal extends SignalingEvent {
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  const IceCandidateSignal({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
  });

  factory IceCandidateSignal.fromJson(Map<String, dynamic> json) {
    final candidateMap = json['candidate'] as Map<String, dynamic>? ?? {};
    return IceCandidateSignal(
      candidate: candidateMap['candidate'] as String? ?? '',
      sdpMid: candidateMap['sdpMid'] as String?,
      sdpMLineIndex: candidateMap['sdpMLineIndex'] as int?,
    );
  }
}

class CallEndedSignal extends SignalingEvent {
  const CallEndedSignal();

  factory CallEndedSignal.fromJson(Map<String, dynamic> json) {
    return const CallEndedSignal();
  }
}

class CallRejectedSignal extends SignalingEvent {
  const CallRejectedSignal();

  factory CallRejectedSignal.fromJson(Map<String, dynamic> json) {
    return const CallRejectedSignal();
  }
}

class CallFailedSignal extends SignalingEvent {
  final String reason;

  const CallFailedSignal({required this.reason});

  factory CallFailedSignal.fromJson(Map<String, dynamic> json) {
    return CallFailedSignal(
      reason: json['reason'] as String? ?? 'Call failed',
    );
  }
}

class UnknownSignal extends SignalingEvent {
  final String? type;
  final Map<String, dynamic> data;

  const UnknownSignal(this.type, this.data);
}
