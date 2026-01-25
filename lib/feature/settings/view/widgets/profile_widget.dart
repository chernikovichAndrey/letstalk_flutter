 import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';

class ProfileWidget extends StatelessWidget {
  final UserModel user;

  const ProfileWidget({
    super.key,
    required this.user,
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
            name: displayName.isNotEmpty ? displayName : user.phone,
            radius: 70,
          ),
          const SizedBox(height: 20),
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
                      color: appColors.glassForeground.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: appColors.glassForeground.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
