import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';

class MessageForward extends StatelessWidget {
  final ForwardedFrom? forwardedFrom;
  final bool isMe;

  const MessageForward({super.key, this.forwardedFrom, this.isMe = false});

  String _forwardFromName({bool showPhone = true}) {
    if (forwardedFrom?.fromName != null && forwardedFrom!.fromName!.isNotEmpty) {
      final user = forwardedFrom!.fromName!.first;
      return user.fullName ?? user.firstName ?? '';
    }
    if (showPhone &&
        forwardedFrom?.fromPhone != null &&
        forwardedFrom!.fromPhone!.isNotEmpty) {
      return forwardedFrom!.fromPhone!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (forwardedFrom == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.s.forwardedFrom,
            style: context.text.bodySmall?.copyWith(
              color: isMe
                  ? context.appColors.messageMeText
                  : context.appColors.messageOtherText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CAvatar(radius: 8, name: _forwardFromName(showPhone: false)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _forwardFromName(),
                  style: context.text.bodySmall?.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
