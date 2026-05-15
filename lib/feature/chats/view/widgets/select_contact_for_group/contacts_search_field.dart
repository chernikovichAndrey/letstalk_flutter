import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactsSearchField extends StatefulWidget {
  final ContactsLoaded state;

  const ContactsSearchField({super.key, required this.state});

  @override
  State<ContactsSearchField> createState() => _ContactsSearchFieldState();
}

class _ContactsSearchFieldState extends State<ContactsSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.query);
  }

  @override
  void didUpdateWidget(covariant ContactsSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.state.query,
        selection: TextSelection.collapsed(offset: widget.state.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Contact> _selectedContacts() {
    return widget.state.allContacts
        .where((contact) =>
            widget.state.selectedContactIds.contains(contact.registeredUserId))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedContacts();
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
        final contact = selected[index];
        if (contact.registeredUserId != null) {
          context.read<ContactsBloc>().add(
                ContactsToggleContactSelection(contact.registeredUserId!),
              );
        }
      },
    );
  }
}
