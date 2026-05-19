import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';

class CallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  const CallActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color iconColor;

    if (isDestructive) {
      backgroundColor = AppColors.error;
      iconColor = AppColors.white;
    } else if (isActive) {
      backgroundColor = AppColors.white;
      iconColor = AppColors.messageDark;
    } else {
      backgroundColor = AppColors.messageLight.withValues(alpha: 0.4);
      iconColor = AppColors.messageDark;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.textXsRegular.copyWith(
            color: AppColors.messageDark,
          ),
        ),
      ],
    );
  }
}
