import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = appColors.glassForeground;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: appColors.glassButtonBackground,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Icon(
                icon,
                color: baseColor,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
