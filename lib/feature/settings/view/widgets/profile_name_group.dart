import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_name_field.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_edit_card.dart';

class ProfileNamesGroup extends StatefulWidget {
  const ProfileNamesGroup({super.key});

  @override
  State<ProfileNamesGroup> createState() => _ProfileNamesGroupState();
}

class _ProfileNamesGroupState extends State<ProfileNamesGroup> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState.user != null) {
      _firstNameController.text =
          profileState.editingFirstName ?? profileState.user!.firstName ?? '';
      _lastNameController.text =
          profileState.editingLastName ?? profileState.user!.lastName ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final hintColor = isDark ? AppColors.grayDark : AppColors.grayLight;
    final dividerColor = isDark
        ? AppColors.messageLight.withValues(alpha: 0.1)
        : AppColors.messageDark.withValues(alpha: 0.1);

    return ProfileEditCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CNameField(
            controller: _firstNameController,
            hintText: context.s.firstName,
            textColor: textColor,
            hintColor: hintColor,
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            onChanged: (value) => context.read<ProfileBloc>().add(
              ProfileUpdateFirstNameEvent(value),
            ),
          ),
          Container(height: 1, color: dividerColor),
          CNameField(
            controller: _lastNameController,
            hintText: context.s.lastName,
            textColor: textColor,
            hintColor: hintColor,
            textInputAction: TextInputAction.done,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            onChanged: (value) => context.read<ProfileBloc>().add(
              ProfileUpdateLastNameEvent(value),
            ),
          ),
        ],
      ),
    );
  }
}
