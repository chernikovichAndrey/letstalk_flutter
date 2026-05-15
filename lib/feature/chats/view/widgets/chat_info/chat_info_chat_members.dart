import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_add_new_member.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_member_item.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoChatMembers extends StatelessWidget {
  const ChatInfoChatMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        final myId = getIt<ProfileBloc>().state.user?.id;
        final membersList = state.chat?.memberInfo ?? [];
        final chatMembers = state.members;
        final isAdmin = state.chat?.role == 'admin';
        final currentRole = state.chat?.role ?? 'member';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isAdmin) ...[
              const ChatInfoAddNewMember(),
              const SizedBox(height: 16),
            ],
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: membersList.length,
              itemBuilder: (context, index) {
                final member = membersList[index];
                final chatMember = chatMembers.firstWhereOrNull(
                  (cm) => cm.userId == member.id,
                );
                return MemberItem(
                  member: member,
                  chatMember: chatMember,
                  isMyself: member.id == myId,
                  showDivider: false,
                  currentUserRole: currentRole,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
