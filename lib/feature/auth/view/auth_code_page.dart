import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:pinput/pinput.dart';

/// Code verification screen shown after a phone number is submitted on
/// [AuthPhonePage]. Mirrors the Figma "code" frames (light + dark themes).
class AuthCodePage extends StatefulWidget {
  const AuthCodePage({super.key});

  @override
  State<AuthCodePage> createState() => _AuthCodePageState();
}

class _AuthCodePageState extends State<AuthCodePage> {
  static const int _codeLength = 6;
  static const int _resendCountdownSec = 30;

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  Timer? _resendTimer;
  int _resendSecondsLeft = _resendCountdownSec;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCountdownSec);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  void _handleVerify() {
    final code = _codeController.text;
    if (code.length < _codeLength) return;
    context.read<AuthBloc>().add(AuthVerifyCode(code: code));
  }

  void _handleResend() {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthCodeSent) return;
    _codeController.clear();
    context.read<AuthBloc>().add(
      AuthSendCode(
        countryCode: state.countryCode,
        phoneNumber: state.phoneNumber,
      ),
    );
    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;
    final subtitleColor =
        isDark ? AppColors.messageLight : AppColors.grayDark;
    final iconColor =
        isDark ? AppColors.messageLight : AppColors.backgroundDark;

    final state = context.watch<AuthBloc>().state;
    final phone = state is AuthCodeSent ? state.phone : '';

    final isCodeComplete = _codeController.text.length == _codeLength;

    return Scaffold(
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
                context.s.authCodeTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headingSmMedium.copyWith(
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.s.authCodeSubtitle(phone),
                textAlign: TextAlign.center,
                style: AppTypography.textMdRegular.copyWith(
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 26),
              _CodePinput(
                controller: _codeController,
                focusNode: _codeFocusNode,
                length: _codeLength,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
                onCompleted: (_) => _handleVerify(),
              ),
              const SizedBox(height: 16),
              _ResendLabel(
                secondsLeft: _resendSecondsLeft,
                isDark: isDark,
                onTap: _handleResend,
              ),
              const Spacer(),
              CButton.primary(
                label: context.s.authCodeConfirm,
                onPressed: isCodeComplete ? _handleVerify : null,
              ),
            ],
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
            }
          },
          child: Icon(Icons.arrow_back_ios_new, color: color, size: 22),
        ),
      ),
    );
  }
}

class _CodePinput extends StatelessWidget {
  const _CodePinput({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.isDark,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final valueColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final inactiveBorder = isDark ? AppColors.grayDark : AppColors.messageLight;

    final defaultPinTheme = PinTheme(
      width: 44,
      height: 52,
      textStyle: AppTypography.headingSmMedium.copyWith(color: valueColor),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.5, color: inactiveBorder),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.5, color: AppColors.brand),
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.5, color: AppColors.brand),
        ),
      ),
    );

    return Pinput(
      controller: controller,
      focusNode: focusNode,
      length: length,
      autofocus: true,
      keyboardType: TextInputType.number,
      separatorBuilder: (_) => const SizedBox(width: 8),
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      showCursor: true,
      cursor: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: 22,
          height: 1.5,
          color: AppColors.brand,
        ),
      ),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}

class _ResendLabel extends StatelessWidget {
  const _ResendLabel({
    required this.secondsLeft,
    required this.isDark,
    required this.onTap,
  });

  final int secondsLeft;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCounting = secondsLeft > 0;

    if (isCounting) {
      return Center(
        child: Text(
          context.s.authCodeResendIn(secondsLeft),
          textAlign: TextAlign.center,
          style: AppTypography.textSmMedium.copyWith(
            color: AppColors.grayLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            context.s.authCodeResend,
            textAlign: TextAlign.center,
            style: AppTypography.textSmMedium.copyWith(
              color: AppColors.brand,
            ),
          ),
        ),
      ),
    );
  }
}
