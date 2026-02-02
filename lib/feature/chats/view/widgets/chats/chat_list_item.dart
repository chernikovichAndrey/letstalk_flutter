import 'package:flutter/material.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final bool isTyping;
  final VoidCallback? onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;

  const ChatListItem({
    super.key,
    required this.chat,
    this.isTyping = false,
    this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse('${dateTimeStr}Z').toLocal();
      final now = DateTime.now();
      
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        // Today: HH:mm
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (dateTime.year != now.year){
        // Other year: dd.MM.yy
        return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${(dateTime.year % 100).toString().padLeft(2, '0')}';
      } else {
        // Other days: dd.MM
        return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '';
    }
  }
  MemberInfo? _getChatMember() {
    final myId = getIt<ProfileBloc>().state.user?.id;
    return chat.memberInfo?.firstWhereOrNull((member) => member.id != myId);
  }

  String? _getMemberAvatar() {
    final member = _getChatMember();
    if (member == null) return null;
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return '${Env.baseUrl}uploads/${member.avatar}';
    }
    return null;
  }

  String? _getMemberName({bool phone = false}) {
    final member = _getChatMember();
    if (member == null) return null;
    if (member.fullName != null && member.fullName!.isNotEmpty) {
      return member.fullName;
    }
    if (member.firstName != null && member.firstName!.isNotEmpty) {
      return member.firstName;
    }
    if (phone && member.phone != null && member.phone!.isNotEmpty) {
      return member.phone;
    }
    return null;
  }

  String _lastMessagePreview(BuildContext context) {
    if (isTyping) {
      return context.s.typing;
    }
    if (chat.lastMessageText != null) {
      return chat.lastMessageText!;
    }
    if (chat.type == 'group' && chat.lastMessageId == 0) {
      return 'Группа создана';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: isSelectionMode
          ? () => onSelect?.call(!isSelected)
          : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CAvatar(
              imageUrl: chat.type == 'group' ? chat.avatar : _getMemberAvatar(),
              name: chat.type == 'group' ? chat.title : _getMemberName(),
              radius: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (chat.type == 'group' ? chat.title : _getMemberName(phone: true)) ?? context.s.noTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(chat.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _lastMessagePreview(context),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.appColors.messageMeBubble,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: TextStyle(
                                color: context.appColors.messageMeText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelectionMode) ...[
              const SizedBox(width: 12),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? context.color.primary
                    : context.color.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
