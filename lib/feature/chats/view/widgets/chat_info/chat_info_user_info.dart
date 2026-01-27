import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/call_info/chat_info_add_contact.dart';
import 'package:lets_talk/feature/chats/view/widgets/call_info/chat_info_row.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoUserInfo extends StatelessWidget {
  const ChatInfoUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = (getIt<ProfileBloc>().state as ProfileLoaded).user.id;
    final member = getIt<ChatDetailsBloc>().state.chat?.memberInfo?.firstWhereOrNull((member) => member.id != myId);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.appColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (member?.phone != null && member!.phone!.isNotEmpty)
                ...[
                  ChatInfoRow(
                    label: 'мобильный',
                    value: member.phone!,
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: context.appColors.divider,
                  ),
                ],
              ChatInfoRow(
                label: 'имя пользователя',
                value: member?.fullName ?? member?.firstName ?? member?.phone ?? '',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ChatInfoAddContact(),
      ],
    );
  }

}