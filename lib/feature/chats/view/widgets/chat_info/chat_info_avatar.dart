import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class ChatInfoAvatar extends StatelessWidget {
  final MemberInfo? member;
  final Chat? chat;

  const ChatInfoAvatar({super.key, this.member, this.chat});

  String? _getMemberAvatar() {
    if (member == null) return null;
    if (member!.avatar != null && member!.avatar!.isNotEmpty) {
      return member!.avatar;
    }
    return null;
  }

  String? _getMemberName({bool phone = false}) {
    if (member == null) return null;
    if (member!.fullName != null && member!.fullName!.isNotEmpty) {
      return member!.fullName;
    }
    if (member!.firstName != null && member!.firstName!.isNotEmpty) {
      return member!.firstName;
    }
    if (phone && member!.phone != null && member!.phone!.isNotEmpty) {
      return member!.phone;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = chat?.type == 'group';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          if (chat != null && chat?.role == 'admin') {
            context.push(Routes.chatAvatarSheet);
          }
        },
        child: Column(
          children: [
            CAvatar(
              imageUrl: isGroup ? chat?.avatar : _getMemberAvatar(),
              name: isGroup ? chat?.title : _getMemberName(),
              radius: 60,
              isLoading: false,
            ),
            Text(
              isGroup ? chat?.title ?? '' : _getMemberName(phone: true) ?? '',
              style: TextStyle(
                color: context.appColors.glassForeground,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}