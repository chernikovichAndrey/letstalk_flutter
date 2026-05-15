import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const ChatInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final valueColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.textSmRegular.copyWith(color: labelColor),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '',
            style: AppTypography.textMdRegular.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
