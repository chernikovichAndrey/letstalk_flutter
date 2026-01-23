import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_slivers.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chats_app_bar.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>{

  @override
  void initState() {
    super.initState();
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);

  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    if (location == Routes.chats.path && mounted) {
      context.read<ChatsBloc>().add(ChatsRefresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 66;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocBuilder<ChatsBloc, ChatsState>(
            builder: (context, state) {
              if (state is ChatsLoading) {
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
                    state: state,
                    onSelectChat: (id) async {
                      context.push(
                        '${Routes.chats.path}/${Routes.chatDetails.path}'
                            .replaceFirst(':id', id.toString()),
                      );
                      if (context.mounted) {
                        context.read<ChatsBloc>().add(ChatUpdated(id));
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
