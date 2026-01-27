import 'package:flutter/cupertino.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoAddNewMember extends StatelessWidget {
  const ChatInfoAddNewMember({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.addContactToGroupSheet);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_add,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.s.addMembersAction,
              style: const TextStyle(
                color: CupertinoColors.systemBlue,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

}