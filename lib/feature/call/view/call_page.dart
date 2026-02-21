import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/service/webrtc_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/call_avatar.dart';
import 'package:lets_talk/feature/call/view/widgets/call_controllers.dart';
import 'package:lets_talk/feature/call/view/widgets/call_user_avatar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer? _callTimer;
  Duration _duration = Duration.zero;
  final _webRTCService = getIt<WebRTCService>();
  String? _avatar;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
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
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded && context.canPop()) {
            context.pop();
          }
          if (state is CallFailure && context.canPop()) {
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
            _avatar = state.avatar;
            _fullName = state.fullName;
          } else if (state is CallActive) {
            isVideo = state.isVideo;
          } else if (state is CallIncoming) {
            isVideo = state.callType == 'video';
            _avatar = state.callerInfo?.avatar;
            _fullName = state.callerInfo?.fullName;
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
                    placeholderBuilder: (context) => CallAvatar(
                      avatar: _avatar,
                      fullName: _fullName,
                      state: state,
                      duration: _duration,
                    ),
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
                    child: _webRTCService.isVideoEnabled
                        ? RTCVideoView(
                            _webRTCService.localRenderer,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : CallUserAvatar(),
                  ),
                ),
              ] else ...[
                // Audio Call UI - Avatar
                CallAvatar(
                  avatar: _avatar,
                  fullName: _fullName,
                  state: state,
                  duration: _duration,
                ),
              ],
              CallControllers(isVideo: isVideo),
            ],
          );
        },
      ),
    );
  }
}
