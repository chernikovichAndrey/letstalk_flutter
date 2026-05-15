import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/utils/call_details_string_formatter.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_list_unread_badge.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

const double _avatarSize = 60;
const double _hSpacing = 8;
const double _hPadding = 16;
const double _vGap = 4;

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
    if (chat.type == 'group') return chat.title;
    if (chat.type == 'private') return _getMemberName(phone: true);
    if (chat.type == 'favorites') return context.s.favorites;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.messageDark;
    final subtitleColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final timeColor = AppColors.grayLight;
    final dividerColor = isDark
        ? AppColors.white.withValues(alpha: 0.08)
        : AppColors.messageLight;

    return InkWell(
      onTap: isSelectionMode ? () => onSelect?.call(!isSelected) : onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _hPadding,
          top: _vGap,
          bottom: _vGap,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CAvatar(
              imageUrl:
                  chat.type == 'group' ? chat.avatar : _getMemberAvatar(),
              name: chat.type == 'group'
                  ? chat.title
                  : _getMemberName(context: context),
              radius: _avatarSize / 2,
            ),
            const SizedBox(width: _hSpacing),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: dividerColor),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: _hPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _chatTitle(context) ?? context.s.noTitle,
                            style: AppTypography.textMdMedium.copyWith(
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(chat.lastMessageAt, context),
                          style: AppTypography.textSmRegular.copyWith(
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _LastMessagePreview(
                            chat: chat,
                            text: _lastMessagePreview(context),
                            color: subtitleColor,
                            isTyping: isTyping,
                          ),
                        ),
                        if (isSelectionMode) ...[
                          const SizedBox(width: 8),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected
                                ? AppColors.brand
                                : titleColor.withValues(alpha: 0.3),
                          ),
                        ] else if (chat.unreadCount > 0) ...[
                          const SizedBox(width: 4),
                          ChatListUnreadBadge(
                            count: chat.unreadCount,
                            muted: chat.muted,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastMessagePreview extends StatelessWidget {
  final Chat chat;
  final String text;
  final Color color;
  final bool isTyping;

  const _LastMessagePreview({
    required this.chat,
    required this.text,
    required this.color,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textSmRegular.copyWith(color: color);

    if (!isTyping &&
        chat.lastMessageType != null &&
        chat.lastMessageType != 'text') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.attach_file, color: color, size: 16),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              getMessageTypeText(context, chat.lastMessageType ?? ''),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
