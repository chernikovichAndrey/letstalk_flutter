import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/call_info/chat_info_add_new_member.dart';
import 'package:lets_talk/feature/chats/view/widgets/call_info/chat_info_member_item.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoChatMembers extends StatelessWidget {
  const ChatInfoChatMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        final myId = (getIt<ProfileBloc>().state as ProfileLoaded).user.id;
        final membersList = state.chat?.memberInfo ?? [];
        final chatMembers = state.members;
        // final isImAdmin = state.members.firstWhere((member) => member.id == myId).role;
        // print('111111 ${isImAdmin}');

        return Container(
          margin: const EdgeInsets.only(bottom: 22),
          decoration: BoxDecoration(
            color: context.appColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ChatInfoAddNewMember(),
              Container(
                height: 0.5,
                color: context.appColors.glassForeground.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: membersList.length,
                itemBuilder: (context, index) {
                  final member = membersList[index];
                  final chatMember = chatMembers.firstWhere(
                    (cm) => cm.userId == member.id,
                    orElse: () => ChatMember(
                      id: 0,
                      chatId: state.chat?.id ?? 0,
                      userId: member.id,
                      role: 'member',
                      joinedAt: '',
                    ),
                  );

                  return MemberItem(
                    member: member,
                    chatMember: chatMember,
                    isMyself: member.id == myId,
                    showDivider: index < membersList.length - 1,
                    currentUserRole: state.chat?.role ?? 'member',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}