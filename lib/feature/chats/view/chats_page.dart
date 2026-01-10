import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_item.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatsBloc(ChatsRepositoryImpl())..add(ChatsLoad()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.chats),
          elevation: 0,
        ),
        body: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CRefreshableScrollView(
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chat = state.chats[index];
                          return ChatListItem(
                            chat: chat,
                            onTap: () {
                              // TODO: Navigate to chat details
                            },
                          );
                        },
                        childCount: state.chats.length,
                      ),
                    )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final completer = Completer();
    context.read<ChatsBloc>().add(ChatsRefresh(completer));
    return completer.future;
  }
}
