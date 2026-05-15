import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class AddContactToGroupAppBar extends StatelessWidget {
  final bool isDoneEnabled;
  final VoidCallback onDone;

  const AddContactToGroupAppBar({
    super.key,
    required this.isDoneEnabled,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.backgroundLight : const Color(0xFF191919);
    final titleColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: context.pop,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.close,
                size: 28,
                color: iconColor,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.s.addMembersAction,
                style: AppTypography.textLgMedium.copyWith(color: titleColor),
              ),
            ),
          ),
          SizedBox(
            width: 64,
            height: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isDoneEnabled ? onDone : null,
              child: Center(
                child: Text(
                  context.s.ready,
                  style: AppTypography.textMdMedium.copyWith(
                    color: isDoneEnabled
                        ? AppColors.brand
                        : AppColors.brand.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
