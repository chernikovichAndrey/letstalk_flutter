import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/view/widgets/auth_button.dart';
import 'package:pinput/pinput.dart';

class CodeVerificationCard extends StatelessWidget {
  const CodeVerificationCard({
    super.key,
    required this.codeController,
    required this.onVerifyPressed,
  });

  final TextEditingController codeController;
  final VoidCallback onVerifyPressed;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 45,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.5, color: Colors.grey.shade300),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pinput(
            autofocus: true,
            controller: codeController,
            length: 6,
            onCompleted: (_) => onVerifyPressed(),
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: const Border(
                  bottom: BorderSide(width: 2, color: Color(0xFFFFA000)),
                ),
              ),
            ),
            submittedPinTheme: defaultPinTheme,
            showCursor: true,
            cursor: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  width: 22,
                  height: 1,
                  color: const Color(0xFFFFA000),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AuthButton(
            text: context.s.verify,
            onPressed: onVerifyPressed,
          ),
        ],
      ),
    );
  }
}
