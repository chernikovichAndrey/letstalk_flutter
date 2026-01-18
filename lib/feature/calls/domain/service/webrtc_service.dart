import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';

typedef OnIceCandidateCallback = void Function(RTCIceCandidate candidate);
typedef OnTrackCallback = void Function(MediaStream stream);

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final Logger _logger = Logger();

  OnIceCandidateCallback? onIceCandidate;
  OnTrackCallback? onTrack;

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> initialize() async {
    _logger.d('Initializing WebRTCService');
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    _logger.d('Creating PeerConnection');
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      _logger.d('OnIceCandidate: ${candidate.candidate}');
      onIceCandidate?.call(candidate);
    };

    _peerConnection!.onTrack = (event) {
      _logger.d('OnTrack');
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        onTrack?.call(event.streams[0]);
      }
    };
  }

  Future<void> _getUserMedia({bool isVideo = false}) async {
    _logger.d('Getting User Media. Video: $isVideo');
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
              'facingMode': 'user',
            }
          : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      
      _localStream!.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });
    } catch (e) {
      _logger.e('Error getting user media: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer({bool isVideo = false}) async {
    _logger.d('Creating Offer');
    await _createPeerConnection();
    await _getUserMedia(isVideo: isVideo);

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer({
    required RTCSessionDescription remoteDescription,
    bool isVideo = false,
  }) async {
    _logger.d('Creating Answer');
    await _createPeerConnection();
    await _getUserMedia(isVideo: isVideo); // User needs to accept media permissions to answer

    await _peerConnection!.setRemoteDescription(remoteDescription);
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    _logger.d('Setting Remote Description: ${description.type}');
    if (_peerConnection == null) {
      await _createPeerConnection();
    }
    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    _logger.d('Adding ICE Candidate');
    if (_peerConnection != null) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

  Future<void> toggleMute() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = audioTracks[0].enabled;
        audioTracks[0].enabled = !enabled;
        _logger.d('Toggled mute to ${!enabled}');
      }
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks[0]);
        _logger.d('Switched camera');
      }
    }
  }

  Future<void> dispose() async {
    _logger.d('Disposing WebRTCService');
    await _localStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }
}
