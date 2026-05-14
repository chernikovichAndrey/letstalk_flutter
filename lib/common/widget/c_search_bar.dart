import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_search_bar/c_search_bar_badge.dart';

export 'package:lets_talk/common/widget/c_search_bar/c_search_bar_badge.dart'
    show CSearchBarBadgeData;

class CSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;
  final TextEditingController? controller;
  final List<CSearchBarBadgeData> badges;
  final ValueChanged<int>? onBadgeRemoved;

  const CSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.controller,
    this.badges = const [],
    this.onBadgeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.messageDark : AppColors.messageLight;
    final hintColor = isDark ? AppColors.grayDark : AppColors.grayLight;
    final textColor = isDark ? AppColors.white : AppColors.messageDark;
    final hasBadges = badges.isNotEmpty;

    final searchRow = Row(
      children: [
        Icon(Icons.search, color: hintColor, size: 24),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: AppColors.brand,
            style: AppTypography.textMdRegular.copyWith(color: textColor),
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: hintText,
              hintStyle: AppTypography.textMdRegular.copyWith(color: hintColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: Container(
        constraints: hasBadges ? null : const BoxConstraints(minHeight: 44),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: hasBadges ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: hasBadges
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < badges.length; i++)
                        CSearchBarBadge(
                          data: badges[i],
                          onRemoved: onBadgeRemoved == null
                              ? null
                              : () => onBadgeRemoved!(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  searchRow,
                ],
              )
            : searchRow,
      ),
    );
  }
}
