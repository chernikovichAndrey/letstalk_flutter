import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

class AddContactToGroupItem extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const AddContactToGroupItem({
    super.key,
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final nameColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final phoneColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final unselectedColor = isDark
        ? AppColors.grayLight.withValues(alpha: 0.4)
        : AppColors.grayDark.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF9A9A9A).withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 7.5,
                      ),
                    ],
            ),
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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
                        style: AppTypography.textMdMedium
                            .copyWith(color: nameColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (contact.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          contact.phone,
                          style: AppTypography.textSmRegular
                              .copyWith(color: phoneColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 24,
                  color: isSelected ? AppColors.brand : unselectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
