import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CreateChatGroupAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final String? nextLabel;
  final VoidCallback? onPressNext;
  final bool isActionEnabled;

  const CreateChatGroupAppBar({
    super.key,
    this.title,
    this.nextLabel,
    this.onPressNext,
    this.isActionEnabled = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final appColors = context.appColors;

    return AppBar(
      backgroundColor: appColors.backgroundColor,
      surfaceTintColor: appColors.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: context.pop,
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: titleColor,
        ),
      ),
      centerTitle: true,
      title: Text(
        title ?? context.s.newGroup,
        style: AppTypography.textLgMedium.copyWith(color: titleColor),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isActionEnabled ? onPressNext : null,
            child: Center(
              child: Text(
                nextLabel ?? context.s.next,
                style: AppTypography.textMdMedium.copyWith(
                  color: isActionEnabled
                      ? AppColors.brand
                      : AppColors.brand.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
