import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/common/widget/select_call_type_dialog.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class CallContactsSheet extends StatelessWidget {
  const CallContactsSheet({super.key});

  void _onSelectContact(int? id, BuildContext context) {
    if (id != null) {
      SelectCallTypeDialog(id, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsLoad()),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: context.appColors.surfaceSecondary,
          appBar: AppBar(
            backgroundColor: context.appColors.surfaceSecondary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GlassButton(icon: Icons.close, onTap: context.pop),
            ),
            title: Text(
              context.s.newCall,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appColors.glassForeground,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is ContactsLoading ||
                  state is ContactsActionInProgress) {
                return const ContactsSceleton();
              }
              return CustomScrollView(
                slivers: [
                  ContactsSlivers(
                    state: state,
                    onSelectContact:(id) => _onSelectContact(id, context),
                    isRegisteredOnly: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
