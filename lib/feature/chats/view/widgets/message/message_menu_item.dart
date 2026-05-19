import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class MessageMenuItem extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool mirrorIcon;

  const MessageMenuItem({
    super.key,
    required this.title,
    required this.iconAsset,
    required this.onTap,
    this.isDestructive = false,
    this.mirrorIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor =
        isDestructive ? AppColors.error : context.appColors.glassForeground;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isDestructive ? 1.0 : 0.4,
              child: Transform.scale(
                scaleX: mirrorIcon ? -1.0 : 1.0,
                child: SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTypography.textSmRegular.copyWith(color: contentColor),
            ),
          ],
        ),
      ),
    );
  }
}
