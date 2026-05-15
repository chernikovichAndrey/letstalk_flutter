import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoAddNewMember extends StatelessWidget {
  const ChatInfoAddNewMember({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final arrowColor = isDark ? AppColors.grayLight : AppColors.grayDark;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => context.push(Routes.addContactToGroupSheet),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF9A9A9A).withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 7.5,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/profile_add.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.brand,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.s.addMembersAction,
                    style: AppTypography.textMdRegular
                        .copyWith(color: AppColors.brand),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/arrow_right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(arrowColor, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
