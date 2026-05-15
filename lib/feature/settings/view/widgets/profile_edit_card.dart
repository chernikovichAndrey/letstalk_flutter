import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class ProfileEditCard extends StatelessWidget {
  const ProfileEditCard({
    super.key,
    required this.child,
    this.padding,
    this.elevated = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool elevated;
  final VoidCallback? onTap;

  static const double _kRadius = 20;
  static const BoxShadow _kShadow = BoxShadow(
    color: Color(0x26D6D5D5),
    offset: Offset(0, 2),
    blurRadius: 8,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.messageDark : AppColors.white;
    final radius = BorderRadius.circular(_kRadius);

    final paddedChild = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    final card = Material(
      color: bgColor,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: onTap, child: paddedChild)
          : paddedChild,
    );

    if (!isDark && elevated) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [_kShadow],
        ),
        child: card,
      );
    }
    return card;
  }
}
