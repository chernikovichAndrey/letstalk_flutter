import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

class CreateChatGroupContactItem extends StatelessWidget {
  final Contact contact;

  const CreateChatGroupContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          CAvatar(
            imageUrl: contact.imageUrl,
            name: contact.fullName,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName,
                  style: TextStyle(
                    color: context.appColors.glassForeground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  contact.phone,
                  style: TextStyle(
                    color: context.appColors.glassForeground.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}