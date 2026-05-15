import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoActionButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final double width;

  const ChatInfoActionButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final contentColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF9A9A9A).withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 15,
                      spreadRadius: -3,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.textXsRegular
                      .copyWith(color: contentColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
