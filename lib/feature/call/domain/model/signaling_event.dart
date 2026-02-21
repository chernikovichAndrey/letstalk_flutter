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

class CallerInfo {
  final int userId;
  final String phone;
  final String? avatar;
  final String firstName;
  final String lastName;
  final String fullName;

  const CallerInfo({
    required this.userId,
    required this.phone,
    this.avatar,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory CallerInfo.fromJson(Map<String, dynamic> json) {
    return CallerInfo(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
    );
  }
}

class IceServer {
  final List<String> urls;
  final String? username;
  final String? credential;

  const IceServer({
    required this.urls,
    this.username,
    this.credential,
  });

  factory IceServer.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['urls'];
    final urls = rawUrls is List
        ? rawUrls.map((e) => e.toString()).toList()
        : <String>[];
    return IceServer(
      urls: urls,
      username: json['username'] as String?,
      credential: json['credential'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'urls': urls,
        if (username != null) 'username': username,
        if (credential != null) 'credential': credential,
      };
}

class CallIncomingSignal extends SignalingEvent {
  final int callId;
  final int callerId;
  final String offer;
  final String callType;
  final CallerInfo? callerInfo;
  final List<IceServer> iceServers;

  const CallIncomingSignal({
    required this.callId,
    required this.callerId,
    required this.offer,
    this.callType = 'audio',
    this.callerInfo,
    this.iceServers = const [],
  });

  factory CallIncomingSignal.fromJson(Map<String, dynamic> json) {
    final callerInfoJson = json['caller_info'];
    final rawIceServers = json['ice_servers'];
    final iceServers = rawIceServers is List
        ? rawIceServers
            .map((e) => IceServer.fromJson(
                  e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e),
                ))
            .toList()
        : <IceServer>[];
    return CallIncomingSignal(
      callId: int.tryParse(json['call_id'].toString()) ?? 0,
      callerId: int.tryParse(json['caller_id'].toString()) ?? 0,
      offer: json['offer'] as String? ?? '',
      callType: json['call_type'] as String? ?? 'audio',
      callerInfo: callerInfoJson != null
          ? CallerInfo.fromJson(
              callerInfoJson is Map<String, dynamic>
                  ? callerInfoJson
                  : Map<String, dynamic>.from(callerInfoJson),
            )
          : null,
      iceServers: iceServers,
    );
  }
}

class CallAnsweredSignal extends SignalingEvent {
  final int callId;
  final String answer;
  final CallerInfo? callerInfo;

  const CallAnsweredSignal({
    required this.callId,
    required this.answer,
    this.callerInfo,
  });

  factory CallAnsweredSignal.fromJson(Map<String, dynamic> json) {
    final callerInfoJson = json['caller_info'];
    return CallAnsweredSignal(
      callId: int.tryParse(json['call_id'].toString()) ?? 0,
      answer: json['answer'] as String? ?? '',
      callerInfo: callerInfoJson != null
          ? CallerInfo.fromJson(
        callerInfoJson is Map<String, dynamic>
            ? callerInfoJson
            : Map<String, dynamic>.from(callerInfoJson),
      )
          : null,
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
