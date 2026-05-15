import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatContactSheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ChatContactSheetAction({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.messageDark : AppColors.messageLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brand, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    right: 16,
                    top: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Text(
                    title,
                    style: AppTypography.textMdMedium.copyWith(
                      color: AppColors.brand,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
