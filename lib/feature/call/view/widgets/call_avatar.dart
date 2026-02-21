import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class CallAvatar extends StatelessWidget {
  final String? avatar;
  final String? fullName;
  final CallState state;
  final Duration? duration;

  const CallAvatar({
    super.key,
    this.avatar,
    this.fullName,
    required this.state,
    this.duration,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CAvatar(imageUrl: avatar, name: fullName, radius: 80),
            const SizedBox(height: 24),
            Text(
              fullName ?? context.s.defaultUserName,
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
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              )
            else if (state is CallActive && duration != null)
              Text(
                _formatDuration(duration!),
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
