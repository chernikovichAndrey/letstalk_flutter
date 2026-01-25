import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isEnabled;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = iconColor ?? appColors.glassForeground;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? appColors.glassButtonBackground,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? onTap : null,
                child: Icon(
                  icon,
                  color: baseColor,
                  size: size * 0.48, // Scale icon with size (24/50 approx 0.48)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
