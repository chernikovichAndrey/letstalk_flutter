import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_details_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_bubble.dart';

class ChatDetailsPage extends StatefulWidget {
  final int chatId;
  const ChatDetailsPage({super.key, required this.chatId});

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ChatDetailsBloc>().add(ChatDetailsLoadMore(widget.chatId));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
            builder: (context, state) {
              if (state.status == ChatDetailsStatus.initial ||
                  (state.status == ChatDetailsStatus.loading && state.messages.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ChatDetailsStatus.failure && state.messages.isEmpty) {
                return Center(child: Text(state.errorMessage ?? 'Error'));
              }

              return ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
                itemCount: state.hasReachedMax ? state.messages.length : state.messages.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.messages.length) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final message = state.messages[index];
                  final isMe = state.currentUserId != null && message.fromUserId == state.currentUserId;
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                  );
                },
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChatDetailsAppBar(),
          ),
        ],
      ),
    );
  }
}
