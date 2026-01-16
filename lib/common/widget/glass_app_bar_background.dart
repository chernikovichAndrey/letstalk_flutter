import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class GlassAppBarBackground extends StatelessWidget {
  const GlassAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final gradientColors = [
      appColors.glassBackground,
      appColors.glassBackground,
    ];

    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.transparent, Colors.black],
          stops: [0.0, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: gradientColors,
            ),
          ),
        ),
      ),
    );
  }
}
