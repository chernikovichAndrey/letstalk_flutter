import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    required this.backgroundColor,
    required this.iconColor,
    super.key,
  });

  final Color backgroundColor;
  final Color iconColor;

  static const double _size = 96;
  static const double _userIconSize = 40;
  static const double _badgeSize = 32;
  static const double _cameraIconSize = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/user.svg',
              width: _userIconSize,
              height: _userIconSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/camera.svg',
                width: _cameraIconSize,
                height: _cameraIconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.backgroundLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
