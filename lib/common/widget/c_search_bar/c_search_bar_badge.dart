import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CSearchBarBadgeData {
  final String label;
  final Widget? avatar;

  const CSearchBarBadgeData({
    required this.label,
    this.avatar,
  });
}

class CSearchBarBadge extends StatelessWidget {
  final CSearchBarBadgeData data;
  final VoidCallback? onRemoved;

  const CSearchBarBadge({
    super.key,
    required this.data,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.grayDark : AppColors.grayLight;
    final foregroundColor =
        isDark ? AppColors.messageLight : AppColors.backgroundLight;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.avatar != null) ...[
            ClipOval(
              child: SizedBox(
                width: 24,
                height: 24,
                child: data.avatar,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            data.label,
            style: AppTypography.textSmRegular.copyWith(
              height: 1.3,
              color: foregroundColor,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemoved,
            child: Icon(
              Icons.cancel,
              size: 20,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
