import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatListUnreadBadge extends StatelessWidget {
  final int count;
  final bool muted;

  const ChatListUnreadBadge({
    super.key,
    required this.count,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = muted ? context.appColors.hintText : AppColors.brand;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        textAlign: TextAlign.center,
        style: AppTypography.textXsRegular.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}
