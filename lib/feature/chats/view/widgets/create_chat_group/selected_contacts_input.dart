import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/contact_chip.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class SelectedContactsInput extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String searchQuery;
  final String hintText;

  const SelectedContactsInput({
    super.key,
    required this.onSearchChanged,
    required this.hintText,
    this.searchQuery = '',
  });

  @override
  State<SelectedContactsInput> createState() => _SelectedContactsInputState();
}

class _SelectedContactsInputState extends State<SelectedContactsInput> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;
    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Contact> selectedContacts() {
    if (getIt<ContactsBloc>().state is ContactsLoaded) {
      final state = getIt<ContactsBloc>().state as ContactsLoaded;
      return state.allContacts
          .where((contact) => state.selectedContactIds.contains(contact.id))
          .toList();
    } else {
      return [];
    }

  }

  void _removeContact(Contact contact) {
    if (contact.id != null) {
      getIt<ContactsBloc>().add(
        ContactsToggleContactSelection(contact.id!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: selectedContacts().isEmpty ? 60 : 140,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedContacts().isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedContacts().map((contact) {
                  return ContactChip(
                    contact: contact,
                    onRemove: () => _removeContact(contact),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: TextStyle(
                color: context.appColors.glassForeground,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: context.appColors.glassForeground.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
