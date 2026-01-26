import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

class ContactChip extends StatelessWidget {
  final Contact contact;
  final VoidCallback onRemove;

  const ContactChip({
    super.key,
    required this.contact,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal:8, vertical: 6),
        decoration: BoxDecoration(
          color: context.appColors.glassForeground.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CAvatar(
              imageUrl: contact.imageUrl,
              name: contact.fullName,
              radius: 12,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                contact.fullName,
                style: TextStyle(
                  color: context.appColors.glassForeground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.close,
              size: 18,
              color: context.appColors.glassForeground.withValues(alpha: 0.7),
            )
          ],
        ),
      ),
    );
  }
}