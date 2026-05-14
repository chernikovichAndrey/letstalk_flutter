import 'package:lets_talk/feature/call/data/model/ice_servers_response.dart';

class CallOfferResponse {
  final int callId;
  final String callType;
  final String status;
  final int callerId;
  final String offer;
  final List<IceServer>? iceServers;

  CallOfferResponse({
    required this.callId,
    required this.callType,
    required this.status,
    required this.callerId,
    required this.offer,
    this.iceServers,
  });

  factory CallOfferResponse.fromJson(Map<String, dynamic> json) {
    return CallOfferResponse(
      callId: json['call_id'] as int,
      callType: json['call_type'] as String,
      status: json['status'] as String,
      callerId: json['caller_id'] as int,
      offer: json['offer'] as String,
      iceServers: json['ice_servers'] != null
          ? (json['ice_servers'] as List<dynamic>)
              .map((e) => IceServer.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_id': callId,
      'call_type': callType,
      'status': status,
      'caller_id': callerId,
      'offer': offer,
      'ice_servers': iceServers?.map((e) => e.toJson()).toList(),
    };
  }
}
