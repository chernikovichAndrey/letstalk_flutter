import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
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
    final appColors = context.appColors;
    final inputTextStyle = AppTypography.textMdRegular;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leftAction != null) ...[leftAction!, const SizedBox(width: 8)],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appColors.inputSecondaryFill,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.only(left: 20, right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: inputFocus,
                    controller: controller,
                    style: inputTextStyle.copyWith(
                      color: appColors.glassForeground,
                    ),
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: hintText ?? context.s.messageInputHint,
                      hintStyle: inputTextStyle.copyWith(
                        color: appColors.hintText,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (showSendButton) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onSendMessage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/send.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
