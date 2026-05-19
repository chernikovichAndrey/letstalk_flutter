import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ProfileActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final Color labelColor;

  const ProfileActionButton({
    super.key,
    required this.onTap,
    this.icon,
    this.iconColor,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: context.appColors.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.textMdMedium.copyWith(color: labelColor),
                  ),
                ),
              ),
              SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}
