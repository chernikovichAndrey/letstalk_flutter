part of 'call_bloc.dart';

abstract class CallState {}

class CallInitial extends CallState {}

class CallIncoming extends CallState {
  final int callId;
  final int callerId;
  final String offer;
  final String callType;
  final CallerInfo? callerInfo;

  CallIncoming({
    required this.callId,
    required this.callerId,
    required this.offer,
    required this.callType,
    required this.callerInfo,
  });
}

class CallOutgoing extends CallState {
  final int targetUserId;
  final int? callId;
  final bool isVideo;
  final String? avatar;
  final String? fullName;

  CallOutgoing({
    required this.targetUserId,
    required this.isVideo,
    required this.avatar,
    required this.fullName,
    this.callId,
  });

  CallOutgoing copyWith({
    int? targetUserId,
    int? callId,
    bool? isVideo,
    String? avatar,
    String? fullName,
  }) {
    return CallOutgoing(
      targetUserId: targetUserId ?? this.targetUserId,
      callId: callId ?? this.callId,
      isVideo: isVideo ?? this.isVideo,
      avatar: avatar ?? this.avatar,
      fullName: fullName ?? this.fullName,
    );
  }
}

class CallActive extends CallState {
  final int callId;
  final int targetUserId;
  final bool isCaller;
  final bool isVideo;
  final bool isRemoteVideoEnabled;

  CallActive({
    required this.callId,
    required this.targetUserId,
    required this.isCaller,
    required this.isVideo,
    this.isRemoteVideoEnabled = true,
  });

  CallActive copyWith({bool? isRemoteVideoEnabled}) {
    return CallActive(
      callId: callId,
      targetUserId: targetUserId,
      isCaller: isCaller,
      isVideo: isVideo,
      isRemoteVideoEnabled: isRemoteVideoEnabled ?? this.isRemoteVideoEnabled,
    );
  }
}

class CallEnded extends CallState {}

class CallFailure extends CallState {
  final String reason;

  CallFailure(this.reason);
}
