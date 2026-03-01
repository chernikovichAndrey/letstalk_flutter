import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_slivers.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chats_app_bar.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.padding.top + 42;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocBuilder<ChatsBloc, ChatsState>(
            builder: (context, state) {
              final profileStatus = getIt<ProfileBloc>().state.status;
              if (state is ChatsLoading || profileStatus == ProfileStatus.loading) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const ChatListSkeleton(),
                );
              }
              return CRefreshableScrollView(
                edgeOffset: topPadding,
                onRefresh: () => _onRefresh(context),
                slivers: [
                  ChatSlivers(
                    onSelectChat: (id) async {
                      context.push(
                        '${Routes.chats.path}/${Routes.chatDetails.path}',
                        extra: ChatDetailsArgs(chatId: id),
                      );
                      if (context.mounted) {
                        context.read<ChatsBloc>().add(ChatUpdated(chatId: id));
                      }
                    },
                  ),
                ],
              );
            },
          ),
          Positioned(top: 0, left: 0, right: 0, child: const ChatsAppBar()),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final completer = Completer();
    context.read<ChatsBloc>().add(ChatsRefresh(completer));
    return completer.future;
  }
}
