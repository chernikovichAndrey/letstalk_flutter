import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CBottomSheet extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final double? height;
  final bool expand;

  const CBottomSheet({
    super.key,
    required this.children,
    this.title,
    this.height,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final resolvedHeight = expand
        ? (height ?? context.mediaSize.height * 0.65)
        : null;

    return SafeArea(
      top: false,
      child: Container(
        height: resolvedHeight,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: context.pop,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
