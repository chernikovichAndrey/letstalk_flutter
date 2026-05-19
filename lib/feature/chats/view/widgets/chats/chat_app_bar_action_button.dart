import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatAppBarActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPress;
  final bool isRead;

  const ChatAppBarActionButton({
    super.key,
    required this.label,
    required this.onPress,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.appColors.backgroundColor,
          foregroundColor: isRead ? Colors.red : context.appColors.messageOtherText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.textMdSemiBold,
        ),
      ),
    );
  }
}
