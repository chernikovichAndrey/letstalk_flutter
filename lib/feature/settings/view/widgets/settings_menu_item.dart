import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showDivider;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.labelColor,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final defaultLabelColor = isDark
        ? AppColors.messageLight
        : AppColors.messageDark;
    final valueColor = isDark ? AppColors.grayDark : AppColors.grayLight;
    final dividerColor = isDark
        ? AppColors.grayDark
        : AppColors.messageDark.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: context.appColors.divider,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(color: dividerColor, width: 1),
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? labelColor ?? defaultLabelColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor ?? defaultLabelColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: valueColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
