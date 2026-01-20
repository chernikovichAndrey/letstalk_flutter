import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const CSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Shimmer(
        color: context.appColors.skeletonShimmerColor,
        colorOpacity: 0.3,
        duration: const Duration(milliseconds: 1500),
        interval: const Duration(milliseconds: 500),
        child: Container(
          width: width,
          height: height,
          color: context.appColors.skeletonColor,
        ),
      ),
    );
  }
}
