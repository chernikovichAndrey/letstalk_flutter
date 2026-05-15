import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_leading_actions.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_new_call_button.dart';
import 'package:lets_talk/feature/calls_history/view/widgets/call_history_segmented_control.dart';

class CallHistoryAppBar extends StatelessWidget {
  const CallHistoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
        child: Container(
          color: isDark
              ? AppColors.backgroundDark.withValues(alpha: 0.7)
              : AppColors.backgroundLight.withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: const SizedBox(
                height: 40,
                child: Row(
                  children: [
                    CallHistoryLeadingActions(),
                    Expanded(
                      child: Center(child: CallHistorySegmentedControl()),
                    ),
                    CallHistoryNewCallButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
