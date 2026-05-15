import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class ChatInfoAvatar extends StatelessWidget {
  final MemberInfo? member;
  final Chat? chat;

  const ChatInfoAvatar({super.key, this.member, this.chat});

  String? _getMemberAvatar() {
    final avatar = member?.avatar;
    if (avatar != null && avatar.isNotEmpty) return avatar;
    return null;
  }

  String _getMemberName({bool phone = false}) {
    if (member == null) return '';
    final fullName = member!.fullName;
    if (fullName != null && fullName.isNotEmpty) return fullName;
    final firstName = member!.firstName;
    if (firstName != null && firstName.isNotEmpty) return firstName;
    if (phone) {
      final phoneNumber = member!.phone;
      if (phoneNumber != null && phoneNumber.isNotEmpty) return phoneNumber;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final isGroup = chat?.type == 'group';
    final canEditAvatar = isGroup && chat?.role == 'admin';

    final titleColor =
        isDark ? AppColors.backgroundLight : const Color(0xFF191919);
    final subtitleColor =
        isDark ? AppColors.grayLight : AppColors.grayDark;

    final title = isGroup
        ? (chat?.title ?? '')
        : _getMemberName(phone: true);
    final subtitle = isGroup
        ? context.s.participantsCount(chat?.membersCount ?? 0)
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canEditAvatar ? () => context.push(Routes.chatAvatarSheet) : null,
      child: Column(
        children: [
          CAvatar(
            imageUrl: isGroup ? chat?.avatar : _getMemberAvatar(),
            name: isGroup ? chat?.title : _getMemberName(),
            radius: 50,
            isLoading: false,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.headingXsMedium.copyWith(color: titleColor),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.textSmRegular.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
