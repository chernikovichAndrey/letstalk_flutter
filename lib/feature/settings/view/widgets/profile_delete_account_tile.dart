import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/view/widgets/delete_account_dialog.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_edit_card.dart';

class ProfileDeleteAccountTile extends StatelessWidget {
  const ProfileDeleteAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileEditCard(
      elevated: true,
      onTap: () => showDeleteAccountConfirmDialog(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.s.deleteAccount,
              style: AppTypography.textMdSemiBold.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.error, size: 24),
        ],
      ),
    );
  }
}
