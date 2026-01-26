import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/selected_contacts_input.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class CreateChatGroupPage extends StatelessWidget {
  const CreateChatGroupPage({super.key});

  List<Contact> _getSelectedContacts(ContactsLoaded state) {
    return state.allContacts
        .where((contact) => state.selectedContactIds.contains(contact.id))
        .toList();
  }

  void _removeContact(BuildContext context, Contact contact) {
    if (contact.id != null) {
      context.read<ContactsBloc>().add(
        ContactsToggleContactSelection(contact.id!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsToggleSelectionMode()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                if (state is ContactsLoading ||
                    state is ContactsActionInProgress) {
                  return const ContactsSceleton();
                }
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: context.padding.top + 66),
                    ),
                    if (state is ContactsLoaded)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: SelectedContactsInput(
                            selectedContacts: _getSelectedContacts(state),
                            onRemoveContact: (contact) => _removeContact(context, contact),
                            onSearchChanged: (query) {
                              context.read<ContactsBloc>().add(ContactsSearch(query));
                            },
                            searchQuery: state.query,
                          ),
                        ),
                      ),
                    ContactsSlivers(state: state, isRegisteredOnly: false, showSearch: false),
                  ],
                );
              },
            ),
            const CreateChatGroupAppBar(),
          ],
        ),
      ),
    );
  }
}
