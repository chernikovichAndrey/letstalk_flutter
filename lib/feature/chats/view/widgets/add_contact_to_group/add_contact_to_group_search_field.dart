import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class AddContactToGroupSearchField extends StatefulWidget {
  final Set<int> selectedUserIds;
  final ValueChanged<int> onRemove;

  const AddContactToGroupSearchField({
    super.key,
    required this.selectedUserIds,
    required this.onRemove,
  });

  @override
  State<AddContactToGroupSearchField> createState() =>
      _AddContactToGroupSearchFieldState();
}

class _AddContactToGroupSearchFieldState
    extends State<AddContactToGroupSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Contact> _selectedContacts(ContactsLoaded state) {
    return state.allContacts
        .where(
          (c) =>
              c.registeredUserId != null &&
              widget.selectedUserIds.contains(c.registeredUserId),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      builder: (context, state) {
        final selected =
            state is ContactsLoaded ? _selectedContacts(state) : <Contact>[];
        final badges = selected
            .map(
              (c) => CSearchBarBadgeData(
                label: c.fullName,
                avatar: CAvatar(
                  imageUrl: c.imageUrl,
                  name: c.fullName,
                  radius: 12,
                ),
              ),
            )
            .toList();

        return CSearchBar(
          controller: _controller,
          hintText: context.s.search,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          badges: badges,
          onChanged: (value) =>
              context.read<ContactsBloc>().add(ContactsSearch(value)),
          onBadgeRemoved: (index) {
            final id = selected[index].registeredUserId;
            if (id != null) widget.onRemove(id);
          },
        );
      },
    );
  }
}
