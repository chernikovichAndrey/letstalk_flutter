import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

const double _kDialogWidth = 350;
const double _kDialogRadius = 20;
const EdgeInsets _kDialogPadding = EdgeInsets.all(20);
const BoxShadow _kDialogShadow = BoxShadow(
  color: Color(0x26D6D5D5),
  offset: Offset(0, 2),
  blurRadius: 8,
);

void showDeleteAccountConfirmDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) {
      return _DialogShell(
        children: [
          Text(
            dialogContext.s.deleteAccountConfirmTitle,
            style: AppTypography.textLgMedium.copyWith(
              color: _titleColor(dialogContext),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dialogContext.s.deleteAccountConfirmMessage,
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
                label: dialogContext.s.deleteAccountConfirmButton,
                color: AppColors.error,
                onPressed: () {
                  dialogContext.pop();
                  final bloc = context.read<ProfileBloc>();
                  showDeleteAccountCodeDialog(
                    context,
                    bloc.state.user?.phone ?? '',
                  );
                  bloc.add(ProfileRequestDeleteAccountCodeEvent());
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

void showDeleteAccountCodeDialog(BuildContext context, String phone) {
  final codeController = TextEditingController();

  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) {
      return _DialogShell(
        children: [
          Text(
            dialogContext.s.deleteAccountCodeTitle,
            style: AppTypography.textLgMedium.copyWith(
              color: _titleColor(dialogContext),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dialogContext.s.deleteAccountCodeMessage(phone),
            style: AppTypography.textSmRegular.copyWith(
              color: _bodyColor(dialogContext),
            ),
          ),
          const SizedBox(height: 16),
          _CodeInput(
            controller: codeController,
            hint: dialogContext.s.deleteAccountCodeHint,
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
                label: dialogContext.s.deleteAccountCodeButton,
                color: AppColors.error,
                onPressed: () {
                  final code = codeController.text.trim();
                  if (code.isEmpty) return;
                  context.read<ProfileBloc>().add(
                    ProfileDeleteAccountEvent(code),
                  );
                  dialogContext.pop();
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

class _CodeInput extends StatelessWidget {
  const _CodeInput({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.messageLight;
    final textColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final hintColor = AppColors.grayLight;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      autofocus: true,
      style: AppTypography.textMdRegular.copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.textMdRegular.copyWith(color: hintColor),
        filled: true,
        fillColor: fill,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
    );
  }
}
