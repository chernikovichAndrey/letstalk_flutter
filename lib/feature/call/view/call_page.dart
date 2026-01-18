import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume WebRTCService is provided via RepositoryProvider up the tree
    final webRTCService = RepositoryProvider.of<WebRTCService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded) {
            Navigator.of(context).pop();
          }
          if (state is CallFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Call failed: ${state.reason}')),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
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

              // Controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white, size: 32),
                      onPressed: () => webRTCService.toggleMute(),
                      style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.5)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 40),
                      onPressed: () {
                        final state = context.read<CallBloc>().state;
                        if (state is CallActive) {
                          context
                              .read<CallBloc>()
                              .add(CallHangup(callId: state.callId));
                        } else {
                          // For CallOutgoing or others, trigger cleanup.
                          // Passing -1 as we might not have a callId yet.
                          context.read<CallBloc>().add(CallHangup(callId: -1));
                        }
                      },
                      style: IconButton.styleFrom(backgroundColor: Colors.red),
                    ),
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
