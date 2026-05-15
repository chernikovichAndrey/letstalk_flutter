import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/add_contact_to_group/add_contact_to_group_item.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';

class AddContactToGroupList extends StatelessWidget {
  final Set<int> selectedUserIds;
  final Set<int> excludedUserIds;
  final ValueChanged<int> onTap;

  const AddContactToGroupList({
    super.key,
    required this.selectedUserIds,
    required this.excludedUserIds,
    required this.onTap,
  });

  List<Contact> _filterContacts(ContactsLoaded state) {
    return state.contacts.where((c) {
      final id = c.registeredUserId;
      if (id == null) return false;
      if (excludedUserIds.contains(id)) return false;
      return c.isRegistered;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoading || state is ContactsActionInProgress) {
          return const ContactsSceleton();
        }
        if (state is ContactsError) {
          return Center(child: Text(state.message));
        }
        if (state is! ContactsLoaded) {
          return const SizedBox.shrink();
        }

        final contacts = _filterContacts(state);

        if (contacts.isEmpty) {
          return Center(
            child: Text(
              context.s.noContacts,
              style: AppTypography.textMdMedium.copyWith(
                color: context.color.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final id = contact.registeredUserId!;
            return AddContactToGroupItem(
              contact: contact,
              isSelected: selectedUserIds.contains(id),
              onTap: () => onTap(id),
            );
          },
        );
      },
    );
  }
}
