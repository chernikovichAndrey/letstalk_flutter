import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

enum CButtonType { primary, secondary, text, destructive }

enum CButtonSize { small, medium, large }

class CButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final CButtonType type;
  final CButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const CButton({
    super.key,
    required this.title,
    this.onTap,
    this.type = CButtonType.primary,
    this.size = CButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    final appColors = context.appColors;

    switch (type) {
      case CButtonType.primary:
        backgroundColor = appColors.telegramBlue;
        textColor = Colors.white;
        break;
      case CButtonType.secondary:
        backgroundColor = appColors.secondaryBackground;
        textColor = appColors.telegramBlue;
        break;
      case CButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = appColors.telegramBlue;
        break;
      case CButtonType.destructive:
        backgroundColor = Colors.transparent;
        textColor = appColors.destructive;
        break;
    }

    if (onTap == null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      textColor = textColor.withValues(alpha: 0.5);
    }

    final padding = switch (size) {
      CButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      CButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      CButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };

    final fontSize = switch (size) {
      CButtonSize.small => 14.0,
      CButtonSize.medium => 16.0,
      CButtonSize.large => 18.0,
    };

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: fontSize + 2, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: padding,
            child: content,
          ),
        ),
      ),
    );
  }
}
