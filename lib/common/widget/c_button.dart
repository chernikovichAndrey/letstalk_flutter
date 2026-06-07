import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';

/// Visual style variant of [CButton] taken from Figma design system.
///
/// * [primary]   — solid brand background, white label.
/// * [secondary] — light surface in light theme / dark surface in dark theme,
///                 supports a leading icon.
/// * [ghost]     — transparent background, label only.
enum CButtonVariant { primary, secondary, ghost }

/// Reusable button widget that matches the Figma "Buttons / Light" and
/// "Buttons / Dark" components.
///
/// A single widget covers all four states from Figma:
///   * Active   → [CButtonVariant.primary] with non-null [onPressed]
///   * Disabled → [CButtonVariant.primary] with `onPressed == null`
///   * Ghost    → [CButtonVariant.ghost]
///   * Secondary→ [CButtonVariant.secondary] (optionally with [icon])
///
/// Colors are picked automatically based on [Theme.of(context).brightness];
/// every token can still be overridden via the optional parameters.
class CButton extends StatelessWidget {
  const CButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CButtonVariant.primary,
    this.icon,
    this.iconWidget,
    this.width,
    this.height = _kHeight,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.textStyle,
    this.padding,
    this.expand = true,
  });

  /// Convenience constructor for the brand "Active / Disabled" button.
  const CButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    double? width,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: CButtonVariant.primary,
         width: width,
         expand: expand,
       );

  /// Convenience constructor for the "Secondary" button with an optional icon.
  const CButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Widget? iconWidget,
    double? width,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: CButtonVariant.secondary,
         icon: icon,
         iconWidget: iconWidget,
         width: width,
         expand: expand,
       );

  /// Convenience constructor for the borderless "Ghost" button.
  const CButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    double? width,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: CButtonVariant.ghost,
         width: width,
         expand: expand,
       );

  final String label;
  final VoidCallback? onPressed;
  final CButtonVariant variant;

  /// Leading icon — primarily used by [CButtonVariant.secondary] but may be
  /// supplied to any variant.
  final IconData? icon;

  /// Custom leading widget (e.g. SVG) that overrides [icon].
  final Widget? iconWidget;

  /// Fixed width in logical pixels. If null and [expand] is true, the button
  /// stretches to fill the available horizontal space.
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  /// When true and [width] is null, expands to the parent's max width.
  final bool expand;

  static const double _kHeight = 56;
  static const double _kRadius = 30;
  static const double _kIconSize = 20;
  static const double _kIconGap = 8;
  static const EdgeInsets _kSecondaryPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(_kRadius);

    final resolvedBackground = _resolveBackground(isDark);
    final resolvedForeground = _resolveForeground(isDark);

    final effectivePadding = padding ?? _resolvePadding();

    final hasLeading = iconWidget != null || icon != null;
    final Widget? leading = iconWidget ?? _buildIcon(resolvedForeground);

    final Widget content = Row(
      mainAxisSize: expand && width == null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasLeading) ...[
          leading!,
          const SizedBox(width: _kIconGap),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: (textStyle ?? AppTypography.textMdSemiBold).copyWith(
              color: resolvedForeground,
            ),
          ),
        ),
      ],
    );

    return Container(
      width: width ?? (expand ? double.infinity : null),
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: variant == CButtonVariant.ghost
            ? null
            : const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: resolvedBackground,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: radius,
          child: Padding(
            padding: effectivePadding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Widget? _buildIcon(Color color) {
    if (iconWidget != null) return iconWidget;
    if (icon == null) return null;
    return Icon(icon, size: _kIconSize, color: color);
  }

  EdgeInsetsGeometry _resolvePadding() {
    switch (variant) {
      case CButtonVariant.secondary:
        return _kSecondaryPadding;
      case CButtonVariant.primary:
      case CButtonVariant.ghost:
        return EdgeInsets.zero;
    }
  }

  Color _resolveBackground(bool isDark) {
    switch (variant) {
      case CButtonVariant.primary:
        if (_isEnabled) {
          return backgroundColor ?? AppColors.brand;
        }
        return disabledBackgroundColor ??
            (isDark ? AppColors.grayDark : AppColors.grayLight);
      case CButtonVariant.secondary:
        if (_isEnabled) {
          return backgroundColor ??
              (isDark ? AppColors.messageDark : AppColors.white);
        }
        return disabledBackgroundColor ??
            (isDark ? AppColors.grayDark : AppColors.grayLight);
      case CButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _resolveForeground(bool isDark) {
    switch (variant) {
      case CButtonVariant.primary:
        if (_isEnabled) {
          return foregroundColor ?? AppColors.white;
        }
        return disabledForegroundColor ??
            (isDark ? AppColors.grayLight : AppColors.backgroundLight);
      case CButtonVariant.secondary:
        if (_isEnabled) {
          return foregroundColor ??
              (isDark ? AppColors.white : AppColors.messageDark);
        }
        return disabledForegroundColor ??
            (isDark ? AppColors.grayLight : AppColors.backgroundLight);
      case CButtonVariant.ghost:
        if (_isEnabled) {
          return foregroundColor ??
              (isDark ? AppColors.backgroundLight : AppColors.messageDark);
        }
        return disabledForegroundColor ?? AppColors.grayLight;
    }
  }
}
