import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class GlassButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double? iconSize;
  final bool isEnabled;

  const GlassButton({
    super.key,
    this.icon,
    this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
    this.iconSize,
    this.isEnabled = true,
  }) : assert(
         icon != null || label != null,
         'Either icon or label must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = iconColor ?? appColors.glassForeground;
    final isLabelMode = label != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isLabelMode ? size / 2 : size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: size,
            constraints: isLabelMode
                ? null
                : BoxConstraints.tightFor(width: size, height: size),
            decoration: BoxDecoration(
              color: backgroundColor ?? appColors.glassButtonBackground,
              borderRadius: BorderRadius.circular(
                isLabelMode ? size / 2 : size / 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? onTap : null,
                child: isLabelMode
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: size * 0.4),
                        child: Center(
                          child: Text(
                            label!,
                            style: AppTypography.textMdSemiBold.copyWith(
                              color: baseColor,
                              fontSize: size * 0.32,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(icon!, color: baseColor, size: iconSize ?? size * 0.48),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
