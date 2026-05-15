import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryPermissionView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const GalleryPermissionView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.grayLight : AppColors.grayDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: mutedColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.textMdSemiBold.copyWith(
                color: isDark ? AppColors.white : AppColors.messageDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.textSmRegular.copyWith(color: mutedColor),
            ),
            const SizedBox(height: 16),
            CButton.secondary(
              label: context.s.openSettings,
              onPressed: openAppSettings,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}
