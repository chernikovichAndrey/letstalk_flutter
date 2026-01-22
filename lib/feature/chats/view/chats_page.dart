import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/router_observers.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_item.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats_app_bar.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with RouteAware {
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatsRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    chatsRouteObserver.unsubscribe(this);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<ChatsBloc>().add(ChatsRefresh());
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ChatsBloc>().add(ChatsSearch(query));
      }
    });
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

                  SliverToBoxAdapter(
                    child: CSearchBar(
                      hintText: context.s.search,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (state is ChatsError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(state.message)),
                    )
                  else if (state is ChatsLoaded)
                    if (state.chats.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text(context.s.noChats)),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          final chat = state.chats[index];
                          final isTyping =
                              state.typingUsers[chat.id]?.isNotEmpty ?? false;
                          return ChatListItem(
                            chat: chat,
                            isTyping: isTyping,
                            onTap: () async {
                              context.push(
                                '${Routes.chats.path}/${Routes.chatDetails.path}'
                                    .replaceFirst(':id', chat.id.toString()),
                              );
                              if (context.mounted) {
                                context
                                    .read<ChatsBloc>()
                                    .add(ChatUpdated(chat.id));
                              }
                            },
                          );
                        }, childCount: state.chats.length),
                      )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const ChatsAppBar(),
          ),
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
