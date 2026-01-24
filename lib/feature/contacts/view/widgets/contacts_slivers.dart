import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contact_item.dart';

class ContactsSlivers extends StatelessWidget {
  final Function(int? id)? onSelectContact;
  final bool isRegisteredOnly;

  const ContactsSlivers({
    super.key,
    required this.state,
    this.onSelectContact,
    this.isRegisteredOnly = false,
  });

  final ContactsState state;

  @override
  Widget build(BuildContext context) {
    if (state is ContactsLoaded) {
      final loadedState = state as ContactsLoaded;
      final contacts = isRegisteredOnly
          ? loadedState.contacts.where((contact) => contact.isRegistered).toList()
          : loadedState.contacts;
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: CSearchBar(
              hintText: context.s.search,
              onChanged: (value) {
                context.read<ContactsBloc>().add(ContactsSearch(value));
              },
            ),
          ),
          if (contacts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  context.s.noContacts,
                  style: context.text.titleMedium?.copyWith(
                    color: context.color.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final contact = contacts[index];
                  return ContactItem(
                    contact: contact,
                    state: loadedState,
                    onTap: onSelectContact,
                  );
                },
                childCount: contacts.length,
              ),
            ),
        ],
      );
    } else if (state is ContactsError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text((state as ContactsError).message)),
      );
    } else {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}
