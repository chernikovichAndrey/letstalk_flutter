import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/call_status_line.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: const Alignment(0, -0.18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CAvatar(imageUrl: avatar, name: fullName, radius: 70),
            const SizedBox(height: 12),
            Text(
              fullName ?? context.s.defaultUserName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.messageDark,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            CallStatusLine(state: state, duration: duration),
          ],
        ),
      ),
    );
  }
}
