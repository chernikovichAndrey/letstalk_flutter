import 'package:flutter/cupertino.dart';
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
    setState(() {
      _isSpeakerOn = widget.isVideo;
    });
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
      // Reject
      if (callId != null) {
        getIt<CallBloc>().add(CallRejected(callId: callId));
      }
    } else {
      // Hangup
      if (callId != null) {
        getIt<CallBloc>().add(CallHangup(callId: callId));
      } else {
        getIt<CallBloc>().add(CallHangup(callId: -1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CallActionButton(
              label: context.s.speaker,
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
              onTap: () {
                setState(() {
                  _isSpeakerOn = !_isSpeakerOn;
                });
                _webRTCService.setSpeakerphone(_isSpeakerOn);
              },
            ),
            if (widget.isVideo)
              CallActionButton(
                label: context.s.video,
                icon: _webRTCService.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                onTap: () => _webRTCService.toggleVideo(),
              ),
            CallActionButton(
              label: context.s.mute,
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              onTap: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
                _webRTCService.toggleAudio();
              },
            ),
            CallActionButton(
              label: context.s.endCall,
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              onTap: _onEndCallPress,
            ),
          ],
        ),
      ),
    );
  }
}