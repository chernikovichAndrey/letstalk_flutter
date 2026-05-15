import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/member_info_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_delete_member_button.dart';

class MemberItem extends StatefulWidget {
  final MemberInfo member;
  final ChatMember? chatMember;
  final bool isMyself;
  final bool showDivider;
  final String currentUserRole;

  const MemberItem({
    super.key,
    required this.member,
    required this.chatMember,
    required this.isMyself,
    required this.showDivider,
    required this.currentUserRole,
  });

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  static const _deleteButtonWidth = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_deleteButtonWidth, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDelete(int userId) {
    _controller.reverse();
    context.read<ChatDetailsBloc>().add(RemoveMemberFromChat(userId));
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx / _deleteButtonWidth;
    _controller.value = (_controller.value - delta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (_controller.value > 0) {
      _controller.reverse();
      return;
    }
    if (!widget.isMyself) {
      context.push(
        Routes.memberInfoSheet,
        args: MemberInfoArgs(memberInfo: widget.member),
      );
    }
  }

  String _getRoleLabel(String role) {
    if (role == 'owner' || role == 'admin') return context.s.owner;
    return '';
  }

  String _getMemberName() {
    final m = widget.member;
    if (m.fullName != null && m.fullName!.isNotEmpty) return m.fullName!;
    if (m.firstName != null && m.firstName!.isNotEmpty) return m.firstName!;
    if (m.phone != null && m.phone!.isNotEmpty) return m.phone!;
    return context.s.unknown;
  }

  String? _getMemberAvatar() {
    final avatar = widget.member.avatar;
    if (avatar != null && avatar.isNotEmpty) return avatar;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatMember == null) return const SizedBox.shrink();

    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final nameColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;
    final phoneColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final roleColor = AppColors.grayLight;

    final roleLabel = _getRoleLabel(widget.chatMember!.role);
    final canDelete = widget.currentUserRole == 'admin' && !widget.isMyself;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onHorizontalDragUpdate: canDelete ? _handleDragUpdate : null,
        onHorizontalDragEnd: canDelete ? _handleDragEnd : null,
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              ChatInfoDeleteMemberButton(
                onDelete: () => _onDelete(widget.chatMember!.userId),
                deleteButtonWidth: _deleteButtonWidth,
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF9A9A9A)
                                      .withValues(alpha: 0.1),
                                  offset: const Offset(0, 2),
                                  blurRadius: 7.5,
                                ),
                              ],
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
                      child: Row(
                        children: [
                          CAvatar(
                            imageUrl: _getMemberAvatar(),
                            name: _getMemberName(),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.isMyself
                                      ? context.s.you
                                      : _getMemberName(),
                                  style: AppTypography.textMdMedium
                                      .copyWith(color: nameColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.member.phone ?? '',
                                  style: AppTypography.textSmRegular
                                      .copyWith(color: phoneColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (roleLabel.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              roleLabel,
                              style: AppTypography.textXsRegular
                                  .copyWith(color: roleColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
