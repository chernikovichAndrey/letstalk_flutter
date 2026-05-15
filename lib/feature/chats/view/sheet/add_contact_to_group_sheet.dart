import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/selected_contacts_input.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class AddContactToGroupSheet extends StatefulWidget {
  const AddContactToGroupSheet({super.key});

  @override
  State<AddContactToGroupSheet> createState() => _AddContactToGroupSheetState();
}

class _AddContactToGroupSheetState extends State<AddContactToGroupSheet> {
  @override
  void deactivate() {
    getIt<ContactsBloc>().add(ContactsToggleSelectionMode());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsToggleSelectionMode()),
      child: Container(
        height: context.mediaSize.height * 0.92,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CreateChatGroupAppBar(
            nextLabel: context.s.ready,
            onPressNext: () {
              final contactsState = getIt<ContactsBloc>().state;
              if (contactsState is! ContactsLoaded) return;

              final userIds = contactsState.selectedContactIds.toList();
              for (var userId in userIds) {
                getIt<ChatDetailsBloc>().add(AddMembersToChat(userId));
              }
              context.pop();
            },
          ),
          body: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is ContactsLoading ||
                  state is ContactsActionInProgress) {
                return const ContactsSceleton();
              }
              return CustomScrollView(
                slivers: [
                  if (state is ContactsLoaded)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: SelectedContactsInput(
                          hintText: context.s.groupInviteHint,
                          onSearchChanged: (query) {
                            context.read<ContactsBloc>().add(
                                  ContactsSearch(query),
                                );
                          },
                          searchQuery: state.query,
                        ),
                      ),
                    ),
                  ContactsSlivers(
                    state: state,
                    isRegisteredOnly: true,
                    showSearch: false,
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
