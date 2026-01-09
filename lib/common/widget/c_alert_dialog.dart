import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/dialog_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';

class CAlertDialog extends StatelessWidget {
  const CAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final args = context.getArgsOrNull<DialogArgs>();
    assert(args != null, 'Provide DialogArgs to router args');
    if (args == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const SizedBox.shrink();
    }
    return AlertDialog(
      title: Text(args.title),
      content: Text(args.message),
      actions: [
        TextButton(
          onPressed: () => args.onCancel?.call(context),
          child: Text(args.cancelText ?? ''),
        ),
        TextButton(
          onPressed: () => args.onConfirm?.call(context),
          child: Text(args.confirmText ?? ''),
        ),
      ],
    );
  }
}
