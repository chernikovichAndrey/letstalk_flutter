import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoAvatar extends StatelessWidget {
  const ChatInfoAvatar({super.key});

  MemberInfo? _getChatMember(ChatDetailsState state) {
    final myId = getIt<ProfileBloc>().state.user?.id;
    return state.chat?.memberInfo?.firstWhereOrNull((member) => member.id != myId);
  }

  String? _getMemberAvatar(ChatDetailsState state) {
    final member = _getChatMember(state);
    if (member == null) return null;
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return '${Env.baseUrl}uploads/${member.avatar}';
    }
    return null;
  }

  String? _getMemberName(ChatDetailsState state, {bool phone = false}) {
    final member = _getChatMember(state);
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
      builder: (context, state) {
        final isGroup = state.chat?.type == 'group';
        return Column(
          children: [
            CAvatar(
              imageUrl: isGroup ? state.chat?.avatar : _getMemberAvatar(state),
              name: isGroup ? state.chat?.title : _getMemberName(state),
              radius: 60,
              isLoading: false,
            ),
            Text(
              isGroup ? state.chat?.title ?? '' : _getMemberName(state, phone: true) ?? '',
              style: TextStyle(
                color: context.appColors.glassForeground,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          ],
        );
      },
    );
  }
}