import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

class AuthProfilePage extends StatefulWidget {
  const AuthProfilePage({super.key});

  @override
  State<AuthProfilePage> createState() => _AuthProfilePageState();
}

class _AuthProfilePageState extends State<AuthProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final iconColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final fieldBg = isDark ? AppColors.messageDark : AppColors.messageLight;
    final dividerColor = isDark
        ? AppColors.grayDark
        : AppColors.messageDark.withValues(alpha: 0.1);
    final textColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;

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
                    child: _BackButton(color: iconColor),
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
                  child: _AvatarPlaceholder(
                    backgroundColor: fieldBg,
                    iconColor:
                        isDark ? AppColors.grayLight : AppColors.grayDark,
                  ),
                ),
                const SizedBox(height: 28),
                _NameInputCard(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  backgroundColor: fieldBg,
                  dividerColor: dividerColor,
                  textColor: textColor,
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.authPhone.path);
            }
          },
          child: Icon(Icons.arrow_back_ios_new, color: color, size: 22),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({
    required this.backgroundColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  static const double _size = 96;
  static const double _userIconSize = 40;
  static const double _badgeSize = 32;
  static const double _cameraIconSize = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/user.svg',
              width: _userIconSize,
              height: _userIconSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/camera.svg',
                width: _cameraIconSize,
                height: _cameraIconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.backgroundLight,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameInputCard extends StatelessWidget {
  const _NameInputCard({
    required this.firstNameController,
    required this.lastNameController,
    required this.backgroundColor,
    required this.dividerColor,
    required this.textColor,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final Color backgroundColor;
  final Color dividerColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _NameField(
            controller: firstNameController,
            hintText: context.s.authProfileFirstNameHint,
            textColor: textColor,
            autofocus: true,
            textInputAction: TextInputAction.next,
            padding: const EdgeInsets.only(top: 16, bottom: 12),
          ),
          Container(
            height: 1,
            color: dividerColor,
          ),
          _NameField(
            controller: lastNameController,
            hintText: context.s.authProfileLastNameHint,
            textColor: textColor,
            textInputAction: TextInputAction.done,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
          ),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.padding,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final EdgeInsets padding;
  final bool autofocus;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: textInputAction,
        cursorColor: AppColors.brand,
        cursorWidth: 2,
        style: AppTypography.textMdRegular.copyWith(color: textColor),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTypography.textMdRegular.copyWith(
            color: AppColors.grayLight,
          ),
        ),
      ),
    );
  }
}
