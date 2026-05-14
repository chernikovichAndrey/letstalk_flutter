import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:lets_talk/common/widget/c_phone_input.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';

class AuthPhonePage extends StatefulWidget {
  const AuthPhonePage({super.key});

  @override
  State<AuthPhonePage> createState() => _AuthPhonePageState();
}

class _AuthPhonePageState extends State<AuthPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  CountryCode? _countryCode;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handlePhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_handlePhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneChanged() {
    final isFilled = _phoneController.text.trim().isNotEmpty;
    if (isFilled != _hasInput) {
      setState(() => _hasInput = isFilled);
    }
  }

  void _handleContinuePressed() {
    final dial = _countryCode?.dialCode;
    final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (dial == null || phone.isEmpty) return;

    context.read<AuthBloc>().add(
      AuthSendCode(countryCode: dial, phoneNumber: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final iconColor = isDark ? AppColors.messageLight : AppColors.backgroundDark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 38),
              Center(
                child: Text(
                  context.s.authPhoneTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSmMedium.copyWith(
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              CPhoneInput(
                controller: _phoneController,
                countryCode: _countryCode,
                initialCountryCode:
                    View.of(context).platformDispatcher.locale.countryCode,
                onCountryCodeChanged: (code) {
                  setState(() => _countryCode = code);
                },
                onInit: (code) {
                  if (_countryCode == null && code != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _countryCode = code);
                      }
                    });
                  }
                },
              ),
              const Spacer(),
              CButton.primary(
                label: context.s.continueAction,
                onPressed: _hasInput ? _handleContinuePressed : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
