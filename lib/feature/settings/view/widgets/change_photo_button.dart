import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChangePhotoButton extends StatelessWidget {
  const ChangePhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(Routes.profileAvatarSheet.path),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          context.s.changePhoto,
          style: AppTypography.textMdMedium.copyWith(color: AppColors.brand),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
