 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_action_button.dart';

class ProfileWidget extends StatelessWidget {
  final UserModel user;
  final bool isAvatarUploading;

  const ProfileWidget({
    super.key,
    required this.user,
    this.isAvatarUploading = false,
  });

  String _getUserDisplayName() {
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
    final appColors = context.appColors;
    final displayName = _getUserDisplayName();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          CAvatar(
            imageUrl: user.avatarUrl,
            name: displayName,
            radius: 60,
            isLoading: isAvatarUploading,
          ),
          const SizedBox(height: 16),
          if (displayName.isNotEmpty) ...[
            Text(
              displayName,
              style: TextStyle(
                color: appColors.glassForeground,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.phone,
                style: TextStyle(
                  color: appColors.glassForeground.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              if (user.username != null && user.username!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: appColors.glassForeground.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: appColors.glassForeground.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          const SizedBox(height: 48),
          ProfileActionButton(
            onTap: () => context.push(Routes.profileAvatarSheet.path),
            label: context.s.changePhoto,
            labelColor: appColors.telegramBlue,
            icon: Icons.add_a_photo_outlined,
            iconColor: appColors.telegramBlue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
