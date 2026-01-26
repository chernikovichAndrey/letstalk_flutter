import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatDetailsPageScope extends StatelessWidget {
  const ChatDetailsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (cx, state) {
        final chatId = context.getArgsOrNull<ChatDetailsArgs>()?.chatId;
        if (state is ProfileLoaded && chatId != null) {
          return BlocProvider<ChatDetailsBloc>.value(
            value: getIt()..add(ChatDetailsLoad(chatId, state.user)),
            child: ChatDetailsPage(chatId: chatId),
          );
        }
        return Container();
      },
    );
  }
}
