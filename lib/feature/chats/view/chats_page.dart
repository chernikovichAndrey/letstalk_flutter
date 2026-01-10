import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_item.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_skeleton.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.s.chats),
        toolbarHeight: 30,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          if (state is ChatsLoading) {
            return const ChatListSkeleton();
          }
          return Column(
            children: [
              CSearchBar(
                hintText: context.s.search,
                onChanged: _onSearchChanged,
              ),
              Expanded(
                child: CRefreshableScrollView(
                  onRefresh: () => _onRefresh(context),
                  slivers: [
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
                            return ChatListItem(
                              chat: chat,
                              onTap: () {
                                context.push(
                                  Routes.chatDetails.path.replaceFirst(':id', chat.id.toString()),
                                );
                              },
                            );
                          }, childCount: state.chats.length),
                        )
                    else
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final completer = Completer();
    context.read<ChatsBloc>().add(ChatsRefresh(completer));
    return completer.future;
  }
}
