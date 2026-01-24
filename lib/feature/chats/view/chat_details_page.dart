import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_details/chat_details_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_details/chat_details_date_seporator.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_details/chat_details_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_bubble.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_input/message_input.dart';

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
    return currentScroll >= (maxScroll * 0.8);
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return context.s.today;
    } else if (dateToCompare == yesterday) {
      return context.s.yesterday;
    } else {
      return DateFormat.yMMMMd(
        Localizations.localeOf(context).languageCode,
      ).format(date);
    }
  }

  Widget _renderItem(context, index, state) {
    if (index >= state.messages.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    final message = state.messages[index];
    final isMe =
        state.currentUser?.id != null &&
        message.fromUserId == state.currentUser?.id;

    bool showDate = false;
    final createdAt = DateTime.tryParse(message.createdAt)?.toLocal();

    if (createdAt != null) {
      if (index + 1 < state.messages.length) {
        final nextMessage = state.messages[index + 1];
        final nextCreatedAt = DateTime.tryParse(
          nextMessage.createdAt,
        )?.toLocal();
        if (nextCreatedAt != null) {
          showDate = !_isSameDay(createdAt, nextCreatedAt);
        } else {
          showDate = true;
        }
      } else {
        showDate = true;
      }
    }

    final bubble = MessageBubble(message: message, isMe: isMe);

    if (showDate && createdAt != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DateSeparator(date: _formatDate(createdAt)),
          bubble,
        ],
      );
    }

    return bubble;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatDetailsBloc, ChatDetailsState>(
      listenWhen: (previous, current) =>
          (previous.isDownloadSuccess != current.isDownloadSuccess &&
              current.isDownloadSuccess) ||
          (previous.status != current.status &&
              current.status == ChatDetailsStatus.failure &&
              current.errorMessage != null),
      listener: (context, state) {
        if (state.isDownloadSuccess) {
          showSuccessToast(context.s.fileDownloaded);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
          builder: (context, state) {
            if (state.status == ChatDetailsStatus.initial ||
                (state.status == ChatDetailsStatus.loading &&
                    state.messages.isEmpty)) {
              return const ChatDetailsSkeleton();
            }
            if (state.status == ChatDetailsStatus.failure &&
                state.messages.isEmpty) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }
            final member = state.members.firstWhere(
              (member) => member.userId != state.currentUser?.id,
            );

            return Stack(
              children: [
                ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: context.padding.top + 60,
                    bottom: context.padding.bottom + 80,
                  ),
                  itemCount: state.hasReachedMax
                      ? state.messages.length
                      : state.messages.length + 1,
                  itemBuilder: (context, index) =>
                      _renderItem(context, index, state),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ChatDetailsAppBar(
                    chatTitle: state.chat?.title ?? member.phone ?? '',
                    memberId: member.userId,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: MessageInput(controller: _scrollController),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
