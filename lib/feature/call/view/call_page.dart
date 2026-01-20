import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/call_action_button.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  Timer? _callTimer;
  Duration _duration = Duration.zero;
  final _webRTCService = WebRTCService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<CallBloc>().state;
      bool isVideo = false;
      if (state is CallOutgoing) {
        isVideo = state.isVideo;
      } else if (state is CallActive) {
        isVideo = state.isVideo;
        _startTimer();
      } else if (state is CallIncoming) {
        isVideo = state.callType == 'video';
      }
      _webRTCService.setSpeakerphone(isVideo);

      setState(() {
        _isSpeakerOn = isVideo;
      });
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_callTimer != null) return;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    void onEndCallPress() {
      final state = context.read<CallBloc>().state;
      final callId = switch (state) {
        CallActive(:final callId) => callId,
        CallOutgoing(:final callId) => callId,
        CallIncoming(:final callId) => callId,
        _ => null,
      };

      if (state is CallIncoming) {
        // Reject
        if (callId != null) {
          context.read<CallBloc>().add(CallRejected(callId: callId));
        }
      } else {
        // Hangup
        if (callId != null) {
          context.read<CallBloc>().add(CallHangup(callId: callId));
        } else {
          context.read<CallBloc>().add(CallHangup(callId: -1));
        }
      }
    }

    return Scaffold(
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded && context.canPop()) {
            context.pop();
          }
          if (state is CallFailure && context.canPop()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.s.callFailed(state.reason))),
            );
            context.pop();
          }
          if (state is CallActive && _callTimer == null) {
            _startTimer();
          }
        },
        builder: (context, state) {
          bool isVideo = false;

          if (state is CallOutgoing) {
            isVideo = state.isVideo;
          } else if (state is CallActive) {
            isVideo = state.isVideo;
          } else if (state is CallIncoming) {
            isVideo = state.callType == 'video';
          }

          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: context.appGradients.backgroundGradient,
                  ),
                ),
              ),

              // Video Views (if video call)
              if (isVideo) ...[
                // Remote Video (Full Screen)
                Positioned.fill(
                  child: RTCVideoView(
                    _webRTCService.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),

                // Local Video (Small floating)
                Positioned(
                  right: 20,
                  top: 50,
                  width: 100,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _webRTCService.localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ] else ...[
                // Audio Call UI - Avatar
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        CAvatar(
                          radius: 80,
                          name: context.s.defaultUserName, // Placeholder
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.s.defaultUserName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (state is CallOutgoing)
                          Text(
                            context.s.calling,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          )
                        else if (state is CallActive)
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ],
              Positioned(
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
                      if (isVideo)
                        CallActionButton(
                          label: context.s.video,
                          icon: Icons.video_call,
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
                        onTap: onEndCallPress,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
