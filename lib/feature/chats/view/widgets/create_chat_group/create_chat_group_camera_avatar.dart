import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class CreateChatGroupCameraAvatar extends StatelessWidget {
  final String? avatar;
  final VoidCallback onTap;

  const CreateChatGroupCameraAvatar({
    super.key,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: avatar != null
            ? Image.file(
                File(avatar!),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              )
            : const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.brand,
                size: 24,
              ),
      ),
    );
  }
}
