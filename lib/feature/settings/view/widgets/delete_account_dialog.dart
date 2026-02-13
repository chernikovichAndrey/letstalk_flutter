import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

void showDeleteAccountConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.appColors.surfaceSecondary,
      title: Text(
        context.s.deleteAccountConfirmTitle,
        style: TextStyle(
          color: context.color.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        context.s.deleteAccountConfirmMessage,
        style: TextStyle(
          color: context.color.onSurface,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            context.s.cancel,
            style: TextStyle(color: context.color.onSurface),
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop();
            final bloc = context.read<ProfileBloc>();
            showDeleteAccountCodeDialog(context, bloc.state.user?.phone ?? '');
            bloc.add(ProfileRequestDeleteAccountCodeEvent());
          },
          child: Text(
            context.s.deleteAccountConfirmButton,
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void showDeleteAccountCodeDialog(BuildContext context, String phone) {
  final codeController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.appColors.surfaceSecondary,
      title: Text(
        context.s.deleteAccountCodeTitle,
        style: TextStyle(
          color: context.color.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.s.deleteAccountCodeMessage(phone),
            style: TextStyle(
              color: context.color.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            style: TextStyle(color: context.color.onSurface),
            decoration: InputDecoration(
              hintText: context.s.deleteAccountCodeHint,
              hintStyle: TextStyle(color: context.color.onSurface.withOpacity(0.5)),
              filled: true,
              fillColor: context.appColors.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            context.s.cancel,
            style: TextStyle(color: context.color.onSurface),
          ),
        ),
        TextButton(
          onPressed: () {
            final code = codeController.text.trim();
            if (code.isNotEmpty) {
              context.read<ProfileBloc>().add(ProfileDeleteAccountEvent(code));
              context.pop();
            }
          },
          child: Text(
            context.s.deleteAccountCodeButton,
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
