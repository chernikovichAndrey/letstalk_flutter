import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/call_action_button.dart';

class CallControllers extends StatefulWidget {
  final bool isVideo;

  const CallControllers({super.key, required this.isVideo});

  @override
  State<CallControllers> createState() => _CallControllersState();
}

class _CallControllersState extends State<CallControllers> {
  final _webRTCService = getIt<WebRTCService>();
  bool _isSpeakerOn = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isSpeakerOn = widget.isVideo;
  }

  void _onEndCallPress() {
    final state = getIt<CallBloc>().state;
    final callId = switch (state) {
      CallActive(:final callId) => callId,
      CallOutgoing(:final callId) => callId,
      CallIncoming(:final callId) => callId,
      _ => null,
    };

    if (state is CallIncoming) {
      if (callId != null) {
        getIt<CallBloc>().add(CallRejected(callId: callId));
      }
    } else {
      getIt<CallBloc>().add(CallHangup(callId: callId ?? -1));
    }
  }

  void _onSpeakerTap() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _webRTCService.setSpeakerphone(_isSpeakerOn);
  }

  void _onVideoTap() {
    getIt<CallBloc>().add(
      CallCameraToggleRequested(
        callId: getIt<CallBloc>().state.callId ?? -1,
        enabled: !_webRTCService.isVideoEnabled,
      ),
    );
  }

  void _onMuteTap() {
    setState(() => _isMuted = !_isMuted);
    _webRTCService.toggleAudio();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoEnabled = _webRTCService.isVideoEnabled;

    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CallActionButton(
                label: context.s.speaker,
                icon: Icons.volume_up_rounded,
                isActive: _isSpeakerOn,
                onTap: _onSpeakerTap,
              ),
            ),
            if (widget.isVideo)
              Expanded(
                child: CallActionButton(
                  label: context.s.video,
                  icon: Icons.videocam_outlined,
                  isActive: !isVideoEnabled,
                  onTap: _onVideoTap,
                ),
              ),
            Expanded(
              child: CallActionButton(
                label: context.s.mute,
                icon: Icons.mic_off_outlined,
                isActive: _isMuted,
                onTap: _onMuteTap,
              ),
            ),
            Expanded(
              child: CallActionButton(
                label: context.s.endCall,
                icon: Icons.call_end_rounded,
                isDestructive: true,
                onTap: _onEndCallPress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
