import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/c_list_tile.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  final ContactsLoaded state;

  const ContactItem({super.key, required this.contact, required this.state});

  void _onTapContact(BuildContext context) {
    if (state.isSelectionMode) {
      if (contact.id != null) {
        context.read<ContactsBloc>().add(
          ContactsToggleContactSelection(contact.id!),
        );
      }
      return;
    }
    if (contact.isRegistered) {
      if (contact.registeredUserId != null) {
        context.read<CallBloc>().add(
          CallInitiated(targetUserId: contact.registeredUserId!),
        );
      }
    } else {
      //TODO: send registration sms
    }
  }

  void _onLongTapContact(BuildContext context) {
    if (contact.isRegistered) {
      if (contact.registeredUserId != null) {
        context.read<CallBloc>().add(
          CallInitiated(targetUserId: contact.registeredUserId!, isVideo: true),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedContactIds.contains(contact.id);
    final isRegistered = contact.registeredUserId != null;

    return Opacity(
      opacity: isRegistered ? 1.0 : 0.5,
      child: CListTile(
        onLongTap: () => _onLongTapContact(context),
        leading: CAvatar(
          imageUrl: contact.imageUrl != null && contact.imageUrl!.isNotEmpty
              ? contact.imageUrl
              : null,
          name: contact.fullName,
        ),
        title: contact.fullName,
        subtitle: contact.phone.isNotEmpty ? contact.phone : null,
        trailing: state.isSelectionMode
            ? Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? context.color.primary
                    : context.color.onSurface.withValues(alpha: 0.3),
              )
            : null,
        onTap: () => _onTapContact(context),
      ),
    );
  }
}
