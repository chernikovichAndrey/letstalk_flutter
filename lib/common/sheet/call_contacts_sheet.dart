import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/contacts/data/repository/contacts_repository_impl.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class CallContactsSheet extends StatelessWidget {
  const CallContactsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ContactsBloc(
          ContactsRepositoryImpl(),
          ChatsRepositoryImpl(),
        );
        bloc.add(ContactsLoad());
        return bloc;
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: context.appColors.surfaceSecondary,
          appBar: AppBar(
            backgroundColor: context.appColors.surfaceSecondary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GlassButton(
                icon: Icons.close,
                onTap: context.pop,
              ),
            ),
            title: Text(
              'Новый звонок',
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
              return CustomScrollView(slivers: [ContactsSlivers(state: state)]);
            },
          ),
        ),
      ),
    );
  }
}