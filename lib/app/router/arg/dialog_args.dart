import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/router_args.dart';

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
        title: 'No internet connection',
        message: 'Please check your internet connection and try again.',
        confirmText: 'Retry',
        cancelText: 'Exit',
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
