import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/app/router/arg/MemberInfoArgs.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/toasts.dart';
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
    if (details.delta.dx < 0) {
      final delta = details.delta.dx / _deleteButtonWidth;
      _controller.value = (_controller.value - delta).clamp(0.0, 1.0);
    } else if (details.delta.dx > 0 && _controller.value > 0) {
      final delta = details.delta.dx / _deleteButtonWidth;
      _controller.value = (_controller.value - delta).clamp(0.0, 1.0);
    }
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
    } else {
      if (!widget.isMyself) {
        context.push(
          Routes.memberInfoSheet,
          args: MemberInfoArgs(memberInfo: widget.member),
        );
      }
    }
  }

  String _getRoleLabel(String role, BuildContext context) {
    switch (role) {
      case 'owner':
      case 'admin':
        return context.s.owner;
      case 'member':
      default:
        return '';
    }
  }

  String _getMemberName(BuildContext context, MemberInfo memberInfo) {
    if (memberInfo.fullName != null && memberInfo.fullName!.isNotEmpty) {
      return memberInfo.fullName!;
    }
    if (memberInfo.firstName != null && memberInfo.firstName!.isNotEmpty) {
      return memberInfo.firstName!;
    }
    if (memberInfo.phone != null && memberInfo.phone!.isNotEmpty) {
      return memberInfo.phone!;
    }
    return context.s.unknown;
  }

  String? _getMemberAvatar(MemberInfo memberInfo) {
    if (memberInfo.avatar != null && memberInfo.avatar!.isNotEmpty) {
      return memberInfo.avatar;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatMember == null) return SizedBox();
    final roleLabel = _getRoleLabel(widget.chatMember!.role, context);
    final canDelete = widget.currentUserRole == 'admin' && !widget.isMyself;

    return GestureDetector(
      onHorizontalDragUpdate: canDelete ? _handleDragUpdate : null,
      onHorizontalDragEnd: canDelete ? _handleDragEnd : null,
      onTap: _handleTap,
      child: Column(
        children: [
          ClipRect(
            child: Stack(
              children: [
                ChatInfoDeleteMemberButton(
                  onDelete: () => _onDelete(widget.chatMember!.userId),
                  deleteButtonWidth: _deleteButtonWidth,
                ),
                // Member item content
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _animation.value,
                      child: Container(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoDynamicColor.withBrightness(
                            color: const Color(0xfff2f2f2),
                            darkColor: const Color(0xFF292929),
                          ),
                          context,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CAvatar(
                                imageUrl: _getMemberAvatar(widget.member),
                                name: _getMemberName(context, widget.member),
                                radius: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getMemberName(context, widget.member),
                                      style: TextStyle(
                                        color: context.appColors.glassForeground,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (widget.isMyself)
                                      Text(
                                        context.s.you,
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
                                    color: context.appColors.glassForeground
                                        .withOpacity(0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (widget.showDivider)
            Container(
              height: 0.5,
              color: context.appColors.glassForeground.withOpacity(0.1),
              margin: const EdgeInsets.only(left: 64),
            ),
        ],
      ),
    );
  }
}
