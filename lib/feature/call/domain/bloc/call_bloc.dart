import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/common/service/ringtone_service.dart';
import 'package:lets_talk/feature/call/domain/repository/call_repository.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository _callRepository;
  final WebRTCService _webRTCService = WebRTCService();
  final RingtoneService _ringtoneService = RingtoneService();
  StreamSubscription? _signalingSubscription;

  // Track current call details internally for callbacks
  int? _currentCallId;
  int? _currentTargetUserId;

  CallBloc({required CallRepository callRepository})
      : _callRepository = callRepository,
        super(CallInitial()) {
    on<CallInitiated>(_onCallInitiated);
    on<CallIncomingReceived>(_onCallIncomingReceived);
    on<CallOfferedReceived>(_onCallOfferedReceived);
    on<CallAccepted>(_onCallAccepted);
    on<CallRejected>(_onCallRejected);
    on<CallHangup>(_onCallHangup);
    on<CallSignalingReceived>(_onCallSignalingReceived);

    _init();
  }

  void _init() {
    _signalingSubscription = _callRepository.signalingStream.listen((data) {
      add(CallSignalingReceived(data));
    });

    _webRTCService.onIceCandidate = (candidate) {
      if (_currentTargetUserId != null) {
        _callRepository.sendIceCandidate(
          targetUserId: _currentTargetUserId!,
          candidate: {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        );
      }
    };

    _webRTCService.onTrack = (stream) {
      // Stream handling is typically done via WebRTCService renderers
      // but if we need to update UI state specifically for stream ready, we can emit a state here
      // For now, CallActive implies connection.
    };
  }

  @override
  Future<void> close() {
    _signalingSubscription?.cancel();
    _webRTCService.dispose();
    return super.close();
  }

  Future<void> _onCallInitiated(
    CallInitiated event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _webRTCService.initialize();
      _currentTargetUserId = event.targetUserId;
      emit(CallOutgoing(
        targetUserId: event.targetUserId,
        isVideo: event.isVideo,
      ));

      final offer = await _webRTCService.createOffer(callType: event.isVideo ? CallType.video: CallType.audio);
      await _callRepository.sendOffer(
        targetUserId: event.targetUserId,
        callType: event.isVideo ? 'video' : 'audio',
        sdp: offer.sdp ?? '',
      );
    } catch (e) {
      emit(CallFailure(e.toString()));
    }
  }

  Future<void> _onCallOfferedReceived(
      CallOfferedReceived event,
      Emitter<CallState> emit,
      ) async {
    if (event.status == 'success') {
      final currentState = state as CallOutgoing;
      _currentCallId = event.callId;
      emit(currentState.copyWith(
        callId: event.callId,
      ));
    }
  }

  Future<void> _onCallIncomingReceived(
    CallIncomingReceived event,
    Emitter<CallState> emit,
  ) async {
    // Only accept incoming if not already in a call
    if (state is CallInitial || state is CallEnded || state is CallFailure) {
       await _webRTCService.initialize();
       await _ringtoneService.playIncomingCall();
       _currentCallId = event.callId;
       _currentTargetUserId = event.callerId;
       emit(CallIncoming(
         callId: event.callId,
         callerId: event.callerId,
         offer: event.offer,
         callType: event.callType,
       ));
    }
  }

  Future<void> _onCallAccepted(
    CallAccepted event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _ringtoneService.stop();
      _currentCallId = event.callId;
      _currentTargetUserId = event.callerId;

      // Set remote description (Offer)
      await _webRTCService.setRemoteDescription(
        RTCSessionDescription(event.offer, 'offer'),
      );

      // Create Answer
      final answer = await _webRTCService.createAnswer(
        remoteOffer: RTCSessionDescription(event.offer, 'offer'),
        callType: event.isVideo ? CallType.video : CallType.audio,
      );

      await _callRepository.sendAnswer(
        callId: event.callId,
        sdp: answer.sdp ?? '',
      );

      emit(CallActive(
        callId: event.callId,
        targetUserId: event.callerId,
        isCaller: false,
        isVideo: event.isVideo,
      ));
    } catch (e) {
      emit(CallFailure(e.toString()));
    }
  }

  Future<void> _onCallRejected(
    CallRejected event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.sendReject(callId: event.callId);
      await _cleanup();
      emit(CallEnded());
    } catch (e) {
      emit(CallFailure(e.toString()));
    }
  }

  Future<void> _onCallHangup(
    CallHangup event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.sendHangup(callId: event.callId);
      await _cleanup();
      emit(CallEnded());
    } catch (e) {
      emit(CallFailure(e.toString()));
    }
  }

  Future<void> _onCallSignalingReceived(
    CallSignalingReceived event,
    Emitter<CallState> emit,
  ) async {
    final type = event.data['type'];
    final data = event.data;

    switch (type) {
      case 'call_offered':
        add(CallOfferedReceived(
          callId: int.tryParse(data['call_id']) ?? 0,
          status: data['status'],
        ));
        break;
      case 'call_incoming':
        add(CallIncomingReceived(
          callId: int.tryParse(data['call_id']) ?? 0,
          callerId: data['caller_id'],
          offer: data['offer'],
          callType: data['call_type'] ?? 'audio',
        ));
        break;

      case 'call_answered':
        if (state is CallOutgoing) {
          final isVideo = (state as CallOutgoing).isVideo;
          final sdp = data['answer'];
          await _webRTCService.setRemoteDescription(
            RTCSessionDescription(sdp, 'answer'),
          );

          _currentCallId = data['call_id'];
          emit(CallActive(
            callId: _currentCallId!,
            targetUserId: _currentTargetUserId!,
            isCaller: true,
            isVideo: isVideo,
          ));
        }
        break;

      case 'ice_candidate':
        final candidateMap = data['candidate'];
        if (candidateMap != null) {
          final candidate = RTCIceCandidate(
            candidateMap['candidate'],
            candidateMap['sdpMid'],
            candidateMap['sdpMLineIndex'],
          );
          await _webRTCService.addIceCandidate(candidate);
        }
        break;

      case 'call_ended':
      case 'call_rejected':
      case 'call_failed':
        await _cleanup();
        emit(CallEnded()); // Or CallFailure if failed
        if (type == 'call_failed') {
          emit(CallFailure(data['reason'] ?? 'Call failed'));
        }
        break;
    }
  }

  Future<void> _cleanup() async {
    await _ringtoneService.stop();
    await _webRTCService.endCall();

    _currentCallId = null;
    _currentTargetUserId = null;
  }
}
