import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  final ContactsLoaded state;
  final bool isRegisteredOnly;
  final Function(int? id)? onTap;

  const ContactItem({
    super.key,
    required this.contact,
    required this.state,
    required this.isRegisteredOnly,
    this.onTap,
  });

  void _onTapContact(BuildContext context) {
    if (onTap != null) {
      onTap!(contact.registeredUserId);
      return;
    }
    if (state.isSelectionMode && isRegisteredOnly) {
      if (contact.registeredUserId != null) {
        context.read<ContactsBloc>().add(
          ContactsToggleContactSelection(contact.registeredUserId!),
        );
      }
      return;
    }

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
        context.read<ContactsBloc>().add(
          ContactsCreateChat(contact.registeredUserId!),
        );
      }
    } else {
      //TODO: send registration sms
      showWarningToast(context.s.notWorkingNow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedContactIds.contains(
      isRegisteredOnly ? contact.registeredUserId : contact.id,
    );
    final isRegistered = contact.registeredUserId != null;
    final isDark = context.theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final subtitleColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final borderColor = isDark ? AppColors.messageDark : AppColors.messageLight;

    return Opacity(
      opacity: isRegistered ? 1.0 : 0.5,
      child: InkWell(
        onTap: () => _onTapContact(context),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CAvatar(
                  imageUrl: contact.imageUrl != null && contact.imageUrl!.isNotEmpty
                      ? contact.imageUrl
                      : null,
                  name: contact.fullName,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.fullName,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (contact.phone.isNotEmpty)
                              Text(
                                contact.phone,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (state.isSelectionMode) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.brand
                              : subtitleColor.withValues(alpha: 0.3),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
