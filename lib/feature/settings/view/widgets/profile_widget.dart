import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileWidget extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const ProfileWidget({super.key, this.onAvatarTap});

  String _getUserDisplayName(UserModel user) {
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      return user.fullName!;
    }
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      if (user.lastName != null && user.lastName!.isNotEmpty) {
        return '${user.firstName} ${user.lastName}';
      }
      return user.firstName!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final nameColor = isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final phoneColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final nameWeight = isDark ? FontWeight.w600 : FontWeight.w500;
    final phoneSize = isDark ? 14.0 : 13.0;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const SizedBox.shrink();
        final displayName = _getUserDisplayName(user);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CAvatar(
              imageUrl: user.avatarUrl,
              name: displayName,
              radius: 50,
              isLoading: state.status == ProfileStatus.avatarUploadLoading,
              onTap: onAvatarTap,
            ),
            const SizedBox(height: 12),
            if (displayName.isNotEmpty) ...[
              Text(
                displayName,
                style: AppTypography.headingXsMedium.copyWith(
                  color: nameColor,
                  fontWeight: nameWeight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              user.phone,
              style: AppTypography.textSmRegular.copyWith(
                color: phoneColor,
                fontSize: phoneSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
