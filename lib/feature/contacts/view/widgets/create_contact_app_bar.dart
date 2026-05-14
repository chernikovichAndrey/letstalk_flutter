import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';

class CreateContactAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSave;

  const CreateContactAppBar({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.appColors.surfaceSecondary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GlassButton(icon: Icons.close, onTap: context.pop),
      ),
      title: Text(
        context.s.newContact,
        style: AppTypography.headingXsMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: context.appColors.glassForeground,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: BlocBuilder<AddContactBloc, AddContactState>(
            builder: (context, state) {
              if (state is AddContactInProgress) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return GlassButton(icon: Icons.check, onTap: onSave);
            },
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}