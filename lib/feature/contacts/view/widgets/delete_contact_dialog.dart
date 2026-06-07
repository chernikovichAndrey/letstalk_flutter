import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

const double _kDialogWidth = 350;
const double _kDialogRadius = 20;
const EdgeInsets _kDialogPadding = EdgeInsets.all(20);
const BoxShadow _kDialogShadow = BoxShadow(
  color: Color(0x26D6D5D5),
  offset: Offset(0, 2),
  blurRadius: 8,
);

void showDeleteContactConfirmDialog(BuildContext context, int count) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) {
      return _DialogShell(
        children: [
          Text(
            dialogContext.s.deleteContactConfirmTitle(count),
            style: AppTypography.textLgMedium.copyWith(
              color: _titleColor(dialogContext),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dialogContext.s.deleteContactConfirmMessage(count),
            style: AppTypography.textSmRegular.copyWith(
              color: _bodyColor(dialogContext),
            ),
          ),
          const SizedBox(height: 16),
          _DialogActions(
            children: [
              _DialogTextButton(
                label: dialogContext.s.cancel,
                color: AppColors.grayLight,
                onPressed: () => dialogContext.pop(),
              ),
              _DialogTextButton(
                label: dialogContext.s.delete,
                color: AppColors.error,
                onPressed: () {
                  dialogContext.pop();
                  context.read<ContactsBloc>().add(ContactsDeleteSelected());
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

Color _titleColor(BuildContext context) {
  return context.theme.brightness == Brightness.dark
      ? AppColors.messageLight
      : AppColors.messageDark;
}

Color _bodyColor(BuildContext context) {
  return context.theme.brightness == Brightness.dark
      ? AppColors.messageLight
      : AppColors.grayDark;
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.messageDark : AppColors.white;
    final radius = BorderRadius.circular(_kDialogRadius);

    Widget surface = Material(
      color: bg,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: _kDialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    if (!isDark) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [_kDialogShadow],
        ),
        child: surface,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kDialogWidth),
        child: surface,
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          children[i],
        ],
      ],
    );
  }
}

class _DialogTextButton extends StatelessWidget {
  const _DialogTextButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: AppTypography.textSmMedium.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
