import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoAppBar extends StatelessWidget {
  const ChatInfoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.backgroundLight : const Color(0xFF191919);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(width: 40, height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
