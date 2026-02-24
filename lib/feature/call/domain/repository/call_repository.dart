import 'package:lets_talk/feature/call/data/model/ice_servers_response.dart';

abstract class CallRepository {
  Stream<Map<String, dynamic>> get signalingStream;
  Future<void> sendOffer({
    required int targetUserId,
    required String callType,
    required String sdp,
  });
  Future<void> sendAnswer({
    required int callId,
    required String sdp,
  });
  Future<void> sendIceCandidate({
    required int targetUserId,
    required Map<String, dynamic> candidate,
  });
  Future<void> sendHangup({required int callId});
  Future<void> sendReject({required int callId});
  Future<void> sendCameraToggle({required int callId, required bool enabled});
  Future<IceServersResponse> getIceServers();
}
