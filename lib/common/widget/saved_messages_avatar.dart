import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class SavedMessagesAvatar extends StatelessWidget {
  const SavedMessagesAvatar({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final iconSize = radius * 0.8;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: AppColors.orangeLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/bookmark.svg',
        width: iconSize,
        height: iconSize,
        colorFilter: const ColorFilter.mode(
          AppColors.brand,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
