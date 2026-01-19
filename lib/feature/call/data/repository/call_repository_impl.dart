import 'dart:async';

import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/call/domain/repository/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  final WebSocketService _wsService = WebSocketService();

  @override
  Stream<Map<String, dynamic>> get signalingStream => _wsService.signalingStream;

  @override
  Future<void> sendOffer({
    required int targetUserId,
    required String callType,
    required String sdp,
  }) async {
    _wsService.send({
      'type': 'call_offer',
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
      'type': 'call_answer',
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
      'type': 'ice_candidate',
      'target_user_id': targetUserId,
      'candidate': candidate,
    });
  }

  @override
  Future<void> sendHangup({required int callId}) async {
    _wsService.send({
      'type': 'call_hangup',
      'call_id': callId,
    });
  }

  @override
  Future<void> sendReject({required int callId}) async {
    _wsService.send({
      'type': 'call_reject',
      'call_id': callId,
    });
  }
}
