import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/router_args.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/l10n/generated/l10n.dart';

class DialogArgs extends RouterArgs {
  const DialogArgs._({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  factory DialogArgs.noConnection({required BuildContext context}) =>
      DialogArgs._(
        title: context.s.noConnection,
        message: context.s.noConnectionMessage,
        confirmText: context.s.retry,
        cancelText: context.s.exit,
        onConfirm: (context) {
          context.pop(true);
        },
        onCancel: (context) {
          context.pop(false);
        },
      );

  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final void Function(BuildContext)? onConfirm;
  final void Function(BuildContext)? onCancel;
}
