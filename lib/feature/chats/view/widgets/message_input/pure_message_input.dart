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
          child: TextField(
            focusNode: inputFocus,
            controller: controller,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hintText ?? context.s.messageInputHint,
              filled: true,
              fillColor: context.appColors.inputSecondaryFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              suffixIcon: showSendButton
                  ? IconButton(
                      onPressed: onSendMessage,
                      icon: Icon(Icons.send),
                      color: context.appColors.telegramBlue,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
