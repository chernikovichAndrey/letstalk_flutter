import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

typedef OnIceCandidateCallback = void Function(RTCIceCandidate candidate);
typedef OnTrackCallback = void Function(MediaStream stream);
typedef OnConnectionStateChangeCallback = void Function(RTCPeerConnectionState state);

enum CallType { audio, video }

@singleton
class WebRTCService {
  WebRTCService();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final Logger _logger = Logger();

  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _isInitialized = false;
  bool _remoteDescriptionSet = false;
  List<Map<String, dynamic>>? _iceServers;

  // Callbacks
  OnIceCandidateCallback? onIceCandidate;
  OnTrackCallback? onTrack;
  OnConnectionStateChangeCallback? onConnectionStateChange;

  // Getters
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isInitialized => _isInitialized;
  RTCPeerConnection? get peerConnection => _peerConnection;

  /* ================= INITIALIZATION ================= */

  void setIceServers(List<Map<String, dynamic>> iceServers) {
    _iceServers = iceServers;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('WebRTC already initialized');
      return;
    }

    try {
      _logger.d('WebRTC initializing...');
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _isInitialized = true;
      _logger.i('WebRTC initialized successfully');
    } catch (e) {
      _logger.e('WebRTC initialization failed: $e');
      rethrow;
    }
  }

  /* ================= PEER CONNECTION ================= */

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) {
      _logger.w('PeerConnection already exists');
      return;
    }

    try {
      _logger.d('Creating PeerConnection');

      final defaultIceServers = [
        {'urls': 'stun:stun.relay.metered.ca:80'},
        {
          'urls': 'turn:global.relay.metered.ca:80',
          'username': '4abfeabd2ed84d7afda25bba',
          'credential': 'xzfonFAO6csyuqXb',
        },
        {
          'urls': 'turn:global.relay.metered.ca:80?transport=tcp',
          'username': '4abfeabd2ed84d7afda25bba',
          'credential': 'xzfonFAO6csyuqXb',
        },
        {
          'urls': 'turn:global.relay.metered.ca:443',
          'username': '4abfeabd2ed84d7afda25bba',
          'credential': 'xzfonFAO6csyuqXb',
        },
        {
          'urls': 'turns:global.relay.metered.ca:443?transport=tcp',
          'username': '4abfeabd2ed84d7afda25bba',
          'credential': 'xzfonFAO6csyuqXb',
        },
      ];

      final config = {
        'iceServers': _iceServers,
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 2,
        'iceTransportPolicy': 'all',
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
      };

      final constraints = {
        'mandatory': {},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      };

      _peerConnection = await createPeerConnection(config, constraints);

      _setupPeerConnectionListeners();

      _logger.i('PeerConnection created successfully');
    } catch (e) {
      _logger.e('Failed to create PeerConnection: $e');
      rethrow;
    }
  }

  void _setupPeerConnectionListeners() {
    if (_peerConnection == null) return;

    // ICE Candidate handler
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
        _logger.d('New ICE candidate: ${candidate.candidate}');
        onIceCandidate?.call(candidate);
      }
    };

    // Track handler (remote stream)
    _peerConnection!.onTrack = (RTCTrackEvent event) async {
      _logger.d('onTrack: ${event.track.kind}');
      _remoteStream ??= await createLocalMediaStream('remote');
      _remoteStream!.addTrack(event.track);
      _remoteRenderer.srcObject = _remoteStream;
      _logger.i('Remote ${event.track.kind} track added');
    };

    // Connection state change
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) async {
      _logger.i('Connection state: $state');
      onConnectionStateChange?.call(state);
      if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        await Helper.setAndroidAudioConfiguration(AndroidAudioConfiguration.communication);
      }

      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _logger.i('WebRTC connection established');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _logger.w('WebRTC connection disconnected');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _logger.e('WebRTC connection failed');
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _logger.i('WebRTC connection closed');
          break;
        default:
          break;
      }
    };

    // ICE connection state change
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      _logger.d('ICE connection state: $state');
    };

    // ICE gathering state change
    _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      _logger.d('ICE gathering state: $state');
    };

    // Signaling state change
    _peerConnection!.onSignalingState = (RTCSignalingState state) {
      _logger.d('Signaling state: $state');
    };
  }

  /* ================= MEDIA STREAMS ================= */

  Future<void> _getUserMedia({required CallType callType}) async {
    if (_localStream != null) {
      _logger.w('Local stream already exists');
      return;
    }

    try {
      _logger.d('Getting user media: ${callType.name}');

      final constraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': callType == CallType.video
            ? {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;

      // Add tracks to peer connection
      if (_peerConnection != null) {
        for (final track in _localStream!.getTracks()) {
          await _peerConnection!.addTrack(track, _localStream!);
          _logger.d('Added ${track.kind} track to peer connection');
        }
      }

      _logger.i('User media acquired successfully');
    } catch (e) {
      _logger.e('Failed to get user media: $e');
      rethrow;
    }
  }

  /* ================= OFFER / ANSWER ================= */

  Future<RTCSessionDescription> createOffer({
    CallType callType = CallType.audio,
  }) async {
    try {
      _logger.d('Creating offer for ${callType.name} call');

      await _createPeerConnection();
      await _getUserMedia(callType: callType);

      final offerOptions = {
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': callType == CallType.video,
      };

      final offer = await _peerConnection!.createOffer(offerOptions);
      await _peerConnection!.setLocalDescription(offer);

      _logger.i('Offer created: ${offer.type}');
      return offer;
    } catch (e) {
      _logger.e('Failed to create offer: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer({
    required RTCSessionDescription remoteOffer,
    CallType callType = CallType.audio,
  }) async {
    try {
      _logger.d('Creating answer for ${callType.name} call');

      await _createPeerConnection();
      await _getUserMedia(callType: callType);
      await _setRemoteDescription(remoteOffer);

      final answerOptions = {
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': callType == CallType.video,
      };

      final answer = await _peerConnection!.createAnswer(answerOptions);
      await _peerConnection!.setLocalDescription(answer);

      _logger.i('Answer created: ${answer.type}');
      return answer;
    } catch (e) {
      _logger.e('Failed to create answer: $e');
      rethrow;
    }
  }

  /* ================= SIGNALING ================= */

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _createPeerConnection();
      await _setRemoteDescription(description);
    } catch (e) {
      _logger.e('Failed to set remote description: $e');
      rethrow;
    }
  }

  Future<void> _setRemoteDescription(RTCSessionDescription description) async {
    if (_peerConnection == null) {
      throw Exception('PeerConnection not created');
    }

    _logger.d('Setting remote description: ${description.type}');
    await _peerConnection!.setRemoteDescription(description);
    _remoteDescriptionSet = true;

    // Process pending ICE candidates
    if (_pendingCandidates.isNotEmpty) {
      _logger.d('Adding ${_pendingCandidates.length} pending ICE candidates');
      for (final candidate in _pendingCandidates) {
        await _peerConnection!.addCandidate(candidate);
      }
      _pendingCandidates.clear();
    }

    _logger.i('Remote description set successfully');
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      if (_peerConnection == null || !_remoteDescriptionSet) {
        _logger.d('Buffering ICE candidate (peer connection not ready)');
        _pendingCandidates.add(candidate);
        return;
      }

      _logger.d('Adding ICE candidate');
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      _logger.e('Failed to add ICE candidate: $e');
      // Don't rethrow - ICE candidates can fail without breaking the call
    }
  }

  /* ================= MEDIA CONTROLS ================= */

  Future<bool> toggleAudio() async {
    try {
      final audioTracks = _localStream?.getAudioTracks() ?? [];
      if (audioTracks.isEmpty) {
        _logger.w('No audio tracks available');
        return false;
      }

      final track = audioTracks.first;
      track.enabled = !track.enabled;
      _logger.i('Audio ${track.enabled ? "enabled" : "muted"}');
      return track.enabled;
    } catch (e) {
      _logger.e('Failed to toggle audio: $e');
      return false;
    }
  }

  Future<bool> toggleVideo() async {
    try {
      final videoTracks = _localStream?.getVideoTracks() ?? [];
      if (videoTracks.isEmpty) {
        _logger.w('No video tracks available');
        return false;
      }

      final track = videoTracks.first;
      track.enabled = !track.enabled;
      _logger.i('Video ${track.enabled ? "enabled" : "disabled"}');
      return track.enabled;
    } catch (e) {
      _logger.e('Failed to toggle video: $e');
      return false;
    }
  }

  Future<void> switchCamera() async {
    try {
      final videoTracks = _localStream?.getVideoTracks() ?? [];
      if (videoTracks.isEmpty) {
        _logger.w('No video tracks to switch');
        return;
      }

      await Helper.switchCamera(videoTracks.first);
      _logger.i('Camera switched');
    } catch (e) {
      _logger.e('Failed to switch camera: $e');
    }
  }

  Future<void> setSpeakerphone(bool enabled) async {
    try {
      await Helper.setSpeakerphoneOn(enabled);
      _logger.i('Speakerphone ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      _logger.e('Failed to set speakerphone: $e');
    }
  }

  bool get isAudioEnabled {
    final audioTracks = _localStream?.getAudioTracks() ?? [];
    return audioTracks.isNotEmpty && audioTracks.first.enabled;
  }

  bool get isVideoEnabled {
    final videoTracks = _localStream?.getVideoTracks() ?? [];
    return videoTracks.isNotEmpty && videoTracks.first.enabled;
  }

  bool get isRemoteVideoEnabled {
    final videoTracks = _remoteStream?.getVideoTracks() ?? [];
    return videoTracks.isNotEmpty && videoTracks.first.enabled;
  }

  /* ================= CLEANUP ================= */

  Future<void> endCall() async {
    _logger.d('Ending call and cleaning up resources');

    try {
      // Stop all tracks
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // Clear renderers
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      // Dispose streams
      await _localStream?.dispose();
      _localStream = null;
      _remoteStream = null;

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Clear state
      _pendingCandidates.clear();
      _remoteDescriptionSet = false;

      _logger.i('Call ended and resources cleaned up');
    } catch (e) {
      _logger.e('Error during cleanup: $e');
    }
  }

  Future<void> dispose() async {
    _logger.d('Disposing WebRTC service');

    try {
      await endCall();

      // Dispose renderers
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();

      _isInitialized = false;
      _logger.i('WebRTC service disposed');
    } catch (e) {
      _logger.e('Error during disposal: $e');
    }
  }

  /* ================= STATS & DEBUGGING ================= */

  Future<List<StatsReport>> getConnectionStats() async {
    final stats = await _peerConnection!.getStats();
    return stats;
  }

  String? get connectionState {
    return _peerConnection?.connectionState?.name;
  }

  String? get iceConnectionState {
    return _peerConnection?.iceConnectionState?.name;
  }

  String? get signalingState {
    return _peerConnection?.signalingState?.name;
  }
}
