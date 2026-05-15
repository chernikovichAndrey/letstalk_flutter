import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class SettingsMenuCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsMenuCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
