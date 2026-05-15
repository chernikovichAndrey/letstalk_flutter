import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_camera_avatar.dart';

class CreateChatGroupNameInput extends StatelessWidget {
  final TextEditingController groupNameController;
  final VoidCallback onPressCamera;
  final String? avatar;

  const CreateChatGroupNameInput({
    super.key,
    required this.groupNameController,
    required this.onPressCamera,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.messageDark : AppColors.messageLight;
    final textColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final hintColor =
        isDark ? AppColors.grayDark : AppColors.grayLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CreateChatGroupCameraAvatar(
              avatar: avatar,
              onTap: onPressCamera,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: groupNameController,
                maxLines: 1,
                cursorColor: AppColors.brand,
                style: AppTypography.textMdRegular.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: context.s.groupNameHint,
                  hintStyle:
                      AppTypography.textMdRegular.copyWith(color: hintColor),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
