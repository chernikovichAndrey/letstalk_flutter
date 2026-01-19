import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool _isSpeakerOn = false;

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
      }

      setState(() {
        _isSpeakerOn = isVideo;
      });
      // Set initial speaker state
      // context.read<WebRTCService>().toggleSpeaker(_isSpeakerOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    // We assume WebRTCService is provided via RepositoryProvider up the tree
    final webRTCService = RepositoryProvider.of<WebRTCService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded && context.canPop()) {
            context.pop();
          }
          if (state is CallFailure && context.canPop()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Call failed: ${state.reason}')),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          bool isVideo = false;
          // Check call type based on state
          if (state is CallOutgoing) {
            isVideo = state.isVideo;
          } else if (state is CallActive) {
            isVideo = state.isVideo;
          }

          return Stack(
            children: [
              if (isVideo) ...[
                // Remote Video (Full Screen)
                Positioned.fill(
                  child: RTCVideoView(
                    webRTCService.remoteRenderer,
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
                      webRTCService.localRenderer,
                      mirror: true,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ] else ...[
                // Audio Call UI - Avatar
                const Positioned.fill(
                  child: Center(
                    child: CAvatar(
                      radius: 80,
                      name: 'User', // Placeholder
                    ),
                  ),
                ),
              ],

              // Controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                        // webRTCService.toggleSpeaker(_isSpeakerOn);
                      },
                      style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.5)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white, size: 32),
                      onPressed: () => {},
                      style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.5)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 40),
                      onPressed: () {
                        final state = context.read<CallBloc>().state;
                        final callId = switch (state) {
                          CallActive(:final callId) => callId,
                          CallOutgoing(:final callId) => callId,
                          _ => null,
                        };
                        if (callId != null) {
                          context
                              .read<CallBloc>()
                              .add(CallHangup(callId: callId));
                        } else {
                          // For CallOutgoing or others, trigger cleanup.
                          // Passing -1 as we might not have a callId yet.
                          context.read<CallBloc>().add(CallHangup(callId: -1));
                        }
                      },
                      style: IconButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    if (isVideo)
                      IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 32),
                        onPressed: () => webRTCService.switchCamera(),
                        style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.5)),
                      ),
                  ],
                ),
              ),

              // Status Text
              if (state is CallOutgoing)
                const Center(
                  child: Text(
                    'Calling...',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
