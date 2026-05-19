import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:lets_talk/common/widget/c_name_input_card.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:lets_talk/feature/auth/view/widgets/auth_back_button.dart';
import 'package:lets_talk/feature/auth/view/widgets/avatar_placeholder.dart';

class AuthProfilePage extends StatefulWidget {
  const AuthProfilePage({super.key});

  @override
  State<AuthProfilePage> createState() => _AuthProfilePageState();
}

class _AuthProfilePageState extends State<AuthProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  File? _avatarFile;
  bool _isAvatarLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_handleChanged);
    _lastNameController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_handleChanged);
    _lastNameController.removeListener(_handleChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleChanged() => setState(() {});

  void _handleContinue() {
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) return;
    final lastName = _lastNameController.text.trim();
    context.read<AuthBloc>().add(
      AuthCompleteProfileSetup(
        firstName: firstName,
        lastName: lastName.isEmpty ? null : lastName,
      ),
    );
  }

  Future<void> _handleAvatarTap() async {
    final file = await context.push<File>(Routes.profileAvatarSheet.path);
    if (file != null && mounted) {
      setState(() {
        _avatarFile = file;
        _isAvatarLoading = true;
      });
      try {
        await getIt<AuthRepository>().updateAvatar(file.path);
      } catch (_) {}
      if (mounted) setState(() => _isAvatarLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final iconColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final fieldBg = isDark ? AppColors.messageDark : AppColors.messageLight;

    final isFirstNameValid = _firstNameController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthBackButton(
                    color: iconColor,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(Routes.authPhone.path);
                      }
                    },
                  ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.s.authProfileTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSmMedium.copyWith(
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 56),
                Center(
                  child: AvatarPlaceholder(
                    backgroundColor: fieldBg,
                    iconColor:
                        isDark ? AppColors.grayLight : AppColors.grayDark,
                    localFile: _avatarFile,
                    isLoading: _isAvatarLoading,
                    onTap: _handleAvatarTap,
                  ),
                ),
                const SizedBox(height: 28),
                CNameInputCard(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  firstNameHint: context.s.authProfileFirstNameHint,
                  lastNameHint: context.s.authProfileLastNameHint,
                  autofocus: true,
                ),
                const Spacer(),
                CButton.primary(
                  label: context.s.continueAction,
                  onPressed: isFirstNameValid ? _handleContinue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
