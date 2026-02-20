import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/member_info_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_actions_group.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_avatar.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_user_info.dart';

class MemberInfoSheet extends StatelessWidget {
  const MemberInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final memberInfo = context.getArgsOrNull<MemberInfoArgs>()!.memberInfo;
    return Container(
      height: context.mediaSize.height * 0.92,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        ChatInfoAvatar(member: memberInfo),
                        SizedBox(height: 28,),
                        ChatInfoActionsGroup(member: memberInfo),
                        SizedBox(height: 28,),
                        ChatInfoUserInfo(member: memberInfo),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const ChatInfoAppBar(),
          ],
      ),
    );
  }
}
