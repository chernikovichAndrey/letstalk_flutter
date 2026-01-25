import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_action_button.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class ChatContactsSheet extends StatelessWidget {
  const ChatContactsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ContactsBloc>()..add(ContactsLoad()),
      child: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsChatCreated) {
            context.go(
              '${Routes.chats.path}/${Routes.chatDetails.path}',
              extra: ChatDetailsArgs(chatId: state.chatId),
            );
          }
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
                child: GlassButton(icon: Icons.close, onTap: context.pop),
              ),
              title: Text(
                context.s.writeMessage,
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
                      isRegisteredOnly: true,
                      children: [
                        ChatActionButton(
                          icon: Icons.group_outlined,
                          title: context.s.createGroup,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 12, endIndent: 12,),
                        ChatActionButton(
                            icon: Icons.person_add_outlined,
                            title: context.s.createContact,
                            onTap: () async {
                              await context.push(Routes.createContact.path);
                              if (context.mounted) {
                                context.read<ContactsBloc>().add(ContactsRefresh());
                              }
                            }
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
