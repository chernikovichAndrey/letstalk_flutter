import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_item.dart';

class ChatSlivers extends StatefulWidget {
  final ChatsState state;
  final ValueChanged<int> onSelectChat;
  final int? forwardChatId;

  const ChatSlivers({
    required this.state,
    required this.onSelectChat,
    this.forwardChatId,
    super.key,
  });

  @override
  State<ChatSlivers> createState() => _ChatSliversState();
}

class _ChatSliversState extends State<ChatSlivers> {
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
    final state = widget.state;
    return SliverMainAxisGroup(
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chat = state.chats.where((chat) => chat.id != widget.forwardChatId).toList()[index];
                  final isTyping =
                      state.typingUsers[chat.id]?.isNotEmpty ?? false;
                  final isSelectionMode = state.isSelectionMode;
                  final isSelected = state.selectedChatIds.contains(chat.id);
                  return ChatListItem(
                    chat: chat,
                    isTyping: isTyping,
                    isSelectionMode: isSelectionMode,
                    isSelected: isSelected,
                    onSelect: (_) => context
                        .read<ChatsBloc>()
                        .add(ChatsToggleChatSelection(chat.id)),
                    onTap: () => widget.onSelectChat(chat.id),
                  );
                },
                childCount: state.chats.length - (widget.forwardChatId == null ? 0 : 1),
              ),
            )
        else
          const SliverToBoxAdapter(child: SizedBox.shrink()),
      ],
    );
  }
}
