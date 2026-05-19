import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    required this.backgroundColor,
    required this.iconColor,
    this.localFile,
    this.isLoading = false,
    this.onTap,
    super.key,
  });

  final Color backgroundColor;
  final Color iconColor;
  final File? localFile;
  final bool isLoading;
  final VoidCallback? onTap;

  static const double _size = 96;
  static const double _userIconSize = 40;
  static const double _badgeSize = 32;
  static const double _cameraIconSize = 16;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAvatar(),
          if (isLoading)
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
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

    if (onTap == null) return content;
    return GestureDetector(onTap: isLoading ? null : onTap, child: content);
  }

  Widget _buildAvatar() {
    if (localFile != null) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(localFile!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
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
    );
  }
}
