import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CallHistorySegmentedControl extends StatelessWidget {
  const CallHistorySegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final unselectedColor = isDark ? AppColors.grayLight : AppColors.grayDark;

    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.messageDark : AppColors.messageLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TabBar(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          color: isDark ? AppColors.grayDark : AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: labelColor,
        unselectedLabelColor: unselectedColor,
        labelStyle: AppTypography.textSmMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.textSmMedium.copyWith(
          fontSize: 14,
        ),
        tabs: [
          Tab(
            height: 28,
            child: Text(
              context.s.allCalls,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Tab(
            height: 28,
            child: Text(
              context.s.missedCalls,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
