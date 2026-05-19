import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class CallStatusLine extends StatelessWidget {
  final CallState state;
  final Duration? duration;

  const CallStatusLine({
    super.key,
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
    final textStyle = AppTypography.textMdRegular.copyWith(
      color: AppColors.messageDark,
    );

    if (state is CallActive && duration != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.signal_cellular_alt,
            color: AppColors.messageDark,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(_formatDuration(duration!), style: textStyle),
        ],
      );
    }

    if (state is CallOutgoing) {
      return Text(context.s.calling, style: textStyle);
    }

    return const SizedBox.shrink();
  }
}
