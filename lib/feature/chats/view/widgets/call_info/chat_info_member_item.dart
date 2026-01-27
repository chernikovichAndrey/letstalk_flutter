import 'package:flutter/cupertino.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class MemberItem extends StatelessWidget {
  final MemberInfo member;
  final ChatMember chatMember;
  final bool isMyself;
  final bool showDivider;

  const MemberItem({
    super.key,
    required this.member,
    required this.chatMember,
    required this.isMyself,
    required this.showDivider,
  });

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
      case 'admin':
        return 'владелец';
      case 'member':
      default:
        return '';
    }
  }

  String _getMemberName(MemberInfo memberInfo) {
    if (memberInfo.fullName != null && memberInfo.fullName!.isNotEmpty) {
      return memberInfo.fullName!;
    }
    if (memberInfo.firstName != null && memberInfo.firstName!.isNotEmpty) {
      return memberInfo.firstName!;
    }
    if (memberInfo.phone != null && memberInfo.phone!.isNotEmpty) {
      return memberInfo.phone!;
    }
    return 'Unknown';
  }

  String? _getMemberAvatar(MemberInfo memberInfo) {
    if (memberInfo.avatar != null && memberInfo.avatar!.isNotEmpty) {
      return '${Env.baseUrl}uploads/${memberInfo.avatar}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = _getRoleLabel(chatMember.role);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              CAvatar(
                imageUrl: _getMemberAvatar(member),
                name: _getMemberName(member),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMemberName(member),
                      style: TextStyle(
                        color: context.appColors.glassForeground,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMyself ? 'вы' : '',
                      style: const TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (roleLabel.isNotEmpty)
                Text(
                  roleLabel,
                  style: TextStyle(
                    color: context.appColors.glassForeground.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: context.appColors.glassForeground.withOpacity(0.1),
            margin: const EdgeInsets.only(left: 64),
          ),
      ],
    );
  }
}
