import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ResendLabel extends StatelessWidget {
  const ResendLabel({
    required this.secondsLeft,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final int secondsLeft;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCounting = secondsLeft > 0;

    if (isCounting) {
      return Center(
        child: Text(
          context.s.authCodeResendIn(secondsLeft),
          textAlign: TextAlign.center,
          style: AppTypography.textSmMedium.copyWith(
            color: AppColors.grayLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            context.s.authCodeResend,
            textAlign: TextAlign.center,
            style: AppTypography.textSmMedium.copyWith(
              color: AppColors.brand,
            ),
          ),
        ),
      ),
    );
  }
}
