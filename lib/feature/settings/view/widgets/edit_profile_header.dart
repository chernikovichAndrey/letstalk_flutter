import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key});

  bool _isEnabledSave(ProfileState state) {
    if (state.status == ProfileStatus.loaded) {
      return state.editingFirstName != null ||
          state.editingLastName != null;
    }
    return false;
  }

  void _onSave(BuildContext context) {
    context.read<ProfileBloc>().add(ProfileSaveChangesEvent());
    FocusScope.of(context).unfocus();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 48,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isSaving = state.status == ProfileStatus.saving;
            final isEnabled = _isEnabledSave(state);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    context.s.edit,
                    style: AppTypography.textLgMedium.copyWith(
                      color: titleColor,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: context.pop,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.chevron_left,
                          size: 28,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: isEnabled ? () => _onSave(context) : null,
                            child: Text(
                              context.s.save,
                              style: AppTypography.textMdMedium.copyWith(
                                color: isEnabled
                                    ? AppColors.brand
                                    : AppColors.grayLight,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
