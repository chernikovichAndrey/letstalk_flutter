import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/utils/call_details_string_formatter.dart';
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

  String _formatTime(String? dateTimeStr, BuildContext context) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse('${dateTimeStr}Z').toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final diffDays = today.difference(msgDay).inDays;

      if (diffDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (diffDays < 7) {
        final s = context.s;
        return switch (dateTime.weekday) {
          DateTime.monday => s.weekdayMon,
          DateTime.tuesday => s.weekdayTue,
          DateTime.wednesday => s.weekdayWed,
          DateTime.thursday => s.weekdayThu,
          DateTime.friday => s.weekdayFri,
          DateTime.saturday => s.weekdaySat,
          DateTime.sunday => s.weekdaySun,
          _ => '',
        };
      } else if (dateTime.year != now.year) {
        return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${(dateTime.year % 100).toString().padLeft(2, '0')}';
      } else {
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
      return member.avatar;
    }
    return null;
  }

  String? _getMemberName({bool phone = false, BuildContext? context}) {
    if (chat.type == 'favorites') {
      return context?.s.favorites ?? 'Favorites';
    }
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
    if (isTyping) return context.s.typing;
    if (chat.lastMessageText != null) return chat.lastMessageText!;

    if (chat.lastMessageId == 0) {
      return switch (chat.type) {
        'private' => context.s.chatCreated,
        'favorites' => context.s.favoritesEmptyHint,
        'group' => context.s.groupCreated,
        _ => '',
      };
    }

    return '';
  }

  String? _chatTitle(BuildContext context) {
    if (chat.type == 'group') {
      return chat.title;
    }
    if (chat.type == 'private') {
      return _getMemberName(phone: true);
    }
    if (chat.type == 'favorites') {
      return context.s.favorites;
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
      onTap: isSelectionMode ? () => onSelect?.call(!isSelected) : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: CAvatar(
                imageUrl: chat.type == 'group' ? chat.avatar : _getMemberAvatar(),
                name: chat.type == 'group' ? chat.title : _getMemberName(context: context),
                radius: 28,
              ),
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
                            _chatTitle(context) ?? context.s.noTitle,
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
                          _formatTime(chat.lastMessageAt, context),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 36,
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (chat.lastMessageType != null && chat.lastMessageType != 'text')
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                Text(
                                  getMessageTypeText(context, chat.lastMessageType ?? ''),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              _lastMessagePreview(context),
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: chat.muted ? context.appColors.hintText : context.appColors.messageMeBubble,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
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
      ),
        ),
        Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 84,
          color: context.color.onSurface.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
