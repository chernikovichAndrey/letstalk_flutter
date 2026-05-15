import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

class CreateChatGroupContactItem extends StatelessWidget {
  final Contact contact;

  const CreateChatGroupContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.messageDark : AppColors.messageLight;
    final nameColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final phoneColor =
        isDark ? AppColors.grayLight : AppColors.grayDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          CAvatar(
            imageUrl: contact.imageUrl,
            name: contact.fullName,
            radius: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contact.fullName,
                  style: AppTypography.textMdMedium.copyWith(color: nameColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: AppTypography.textSmRegular.copyWith(color: phoneColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
