import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class PureMessageInput extends StatelessWidget {
  final bool showSendButton;
  final VoidCallback onSendMessage;
  final FocusNode? inputFocus;
  final TextEditingController? controller;
  final Widget? leftAction;
  final String? hintText;

  const PureMessageInput({
    required this.showSendButton,
    required this.onSendMessage,
    this.inputFocus,
    this.controller,
    this.leftAction,
    this.hintText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (leftAction != null) ...[leftAction!, const SizedBox(width: 8)],
        Expanded(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              TextField(
                focusNode: inputFocus,
                controller: controller,
                style: context.text.bodyMedium?.copyWith(
                  letterSpacing: 0,
                  height: 1,
                ),
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: hintText ?? context.s.messageInputHint,
                  hintStyle: context.text.bodyMedium?.copyWith(
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: context.appColors.inputSecondaryFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    right: showSendButton ? 44 : 16,
                    top: 12,
                    bottom: 12,
                  ),
                ),
              ),
              if (showSendButton)
                IconButton(
                  onPressed: onSendMessage,
                  icon: const Icon(Icons.send),
                  color: context.appColors.telegramBlue,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
