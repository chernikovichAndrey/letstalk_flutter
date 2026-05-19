import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class PureMessageInput extends StatefulWidget {
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
  State<PureMessageInput> createState() => _PureMessageInputState();
}

class _PureMessageInputState extends State<PureMessageInput> {
  bool _isMultiline = false;
  double _textFieldWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_checkMultiline);
  }

  @override
  void didUpdateWidget(PureMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_checkMultiline);
      widget.controller?.addListener(_checkMultiline);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_checkMultiline);
    super.dispose();
  }

  void _checkMultiline() {
    if (_textFieldWidth <= 0) return;
    final text = widget.controller?.text ?? '';

    if (text.isEmpty) {
      if (_isMultiline) setState(() => _isMultiline = false);
      return;
    }

    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTypography.textMdRegular),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _textFieldWidth);

    final isMulti = tp.computeLineMetrics().length > 1;
    if (isMulti != _isMultiline) setState(() => _isMultiline = isMulti);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final inputTextStyle = AppTypography.textMdRegular;
    final borderRadius = _isMultiline
        ? BorderRadius.circular(20)
        : BorderRadius.circular(100);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.leftAction != null) ...[
          widget.leftAction!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sendWidth = widget.showSendButton ? 44.0 : 0.0;
              final newWidth = constraints.maxWidth - 36 - sendWidth;
              if (newWidth != _textFieldWidth) {
                _textFieldWidth = newWidth;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: appColors.inputSecondaryFill,
                  borderRadius: borderRadius,
                ),
                padding: const EdgeInsets.only(left: 20, right: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: widget.inputFocus,
                        controller: widget.controller,
                        style: inputTextStyle.copyWith(
                          color: appColors.glassForeground,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? context.s.messageInputHint,
                          hintStyle: inputTextStyle.copyWith(
                            color: appColors.hintText,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (widget.showSendButton) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: widget.onSendMessage,
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
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
