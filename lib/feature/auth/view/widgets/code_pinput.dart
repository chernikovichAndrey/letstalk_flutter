import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:pinput/pinput.dart';

class CodePinput extends StatelessWidget {
  const CodePinput({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.isDark,
    required this.onChanged,
    required this.onCompleted,
    super.key,
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
