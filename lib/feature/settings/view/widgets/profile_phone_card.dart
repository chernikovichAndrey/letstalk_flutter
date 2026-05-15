import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_edit_card.dart';

class ProfilePhoneCard extends StatelessWidget {
  const ProfilePhoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final valueColor = isDark
        ? AppColors.messageLight
        : AppColors.messageDark;

    final labelStyle = AppTypography.textSmMedium.copyWith(
      color: labelColor,
      fontWeight: FontWeight.w400,
    );

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final phone = state.user?.phone ?? '';
        return ProfileEditCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.s.phone, style: labelStyle),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: AppTypography.textMdRegular.copyWith(
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
