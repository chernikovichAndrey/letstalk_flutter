import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CallDetailsInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const CallDetailsInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final valueColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textSmMedium.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.grayLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.textMdMedium.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
