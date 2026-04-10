import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/model/call_signaling_type.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/call/data/model/call_offer_response.dart';
import 'package:lets_talk/feature/call/data/model/ice_servers_response.dart';
import 'package:lets_talk/feature/call/domain/repository/call_repository.dart';

@LazySingleton(as: CallRepository)
class CallRepositoryImpl implements CallRepository {
  final WebSocketService _wsService;
  final ApiService _apiService;

  CallRepositoryImpl(this._wsService, this._apiService);

  @override
  Stream<Map<String, dynamic>> get signalingStream => _wsService.signalingStream;

  @override
  Future<void> sendOffer({
    required int targetUserId,
    required String callType,
    required String sdp,
  }) async {
    _wsService.send({
      'type': CallSignalingType.callOffer.value,
      'target_user_id': targetUserId,
      'call_type': callType,
      'offer': sdp,
    });
  }

  @override
  Future<void> sendAnswer({
    required int callId,
    required String sdp,
  }) async {
    _wsService.send({
      'type': CallSignalingType.callAnswer.value,
      'call_id': callId,
      'answer': sdp,
    });
  }

  @override
  Future<void> sendIceCandidate({
    required int targetUserId,
    required Map<String, dynamic> candidate,
  }) async {
    _wsService.send({
      'type': CallSignalingType.iceCandidate.value,
      'target_user_id': targetUserId,
      'candidate': candidate,
    });
  }

  @override
  Future<void> sendHangup({required int callId}) async {
    _wsService.send({
      'type': CallSignalingType.callHangup.value,
      'call_id': callId,
    });
  }

  @override
  Future<void> sendReject({required int callId}) async {
    _wsService.send({
      'type': CallSignalingType.callReject.value,
      'call_id': callId,
    });
  }

  @override
  Future<void> sendCameraToggle({required int callId, required bool enabled}) async {
    _wsService.send({
      'type': CallSignalingType.callCameraToggle.value,
      'call_id': callId,
      'enabled': enabled,
    });
  }

  @override
  Future<IceServersResponse> getIceServers() async {
    final response = await _apiService.get(ApiConstants.turnCredentials);
    return IceServersResponse.fromJson(response.data);
  }

  @override
  Future<CallOfferResponse> getCallOffer(int callId) async {
    final response = await _apiService.get(ApiConstants.callOffer(callId));
    return CallOfferResponse.fromJson(response.data);
  }
}
