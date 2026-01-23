import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_bubble.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_menu.dart';

class MessageActionsOverlay extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageActionsOverlay({
    super.key,
    required this.message,
    required this.isMe,
  });

  static void show(BuildContext context, Message message, bool isMe) {
    final chatDetailsBloc = context.read<ChatDetailsBloc>();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => BlocProvider.value(
          value: chatDetailsBloc,
          child: MessageActionsOverlay(message: message, isMe: isMe),
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<MessageActionsOverlay> createState() => _MessageActionsOverlayState();
}

class _MessageActionsOverlayState extends State<MessageActionsOverlay> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onCopyMessage() async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.message.text ?? '',
      ),
    );
    if (context.mounted) {
      context.pop();
    }
  }

  void _onEditMessage() {
    if (_canEdit(widget.message)) {
      context.read<ChatDetailsBloc>().add(
        ChatDetailsSetEditingMessage(
            widget.message),
      );
      if (context.mounted) {
        context.pop();
      }
    }
  }

  void _onForwardMessage() {
    context.pop();
    context.push(
      Routes.forwardMessage.path,
      extra: ForwardMessageArgs(
        messageId: widget.message.id,
        chatId: widget.message.chatId,
      ),
    );
  }

  void _onDeleteMessage() {
    context.read<ChatDetailsBloc>().add(
      ChatDetailsDeleteMessage(widget.message.id),
    );
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.pop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Blur effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

            // Content
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: const Alignment(0, 0.6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 60),
                            IgnorePointer(
                              child: MessageBubble(
                                message: widget.message,
                                isMe: widget.isMe,
                              ),
                            ),
                            const SizedBox(height: 8),
                            MessageMenu(
                              isMe: widget.isMe,
                              onCopy: _onCopyMessage,
                              onEdit: _onEditMessage,
                              onForward: _onForwardMessage,
                              onDelete: _onDeleteMessage,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canEdit(Message message) {
    if (!widget.isMe) return false;
    // Check if message text is empty (already handled by model but good to check)
    if (message.text == null || message.text!.isEmpty) return false;
    
    try {
      // Handle date format "YYYY-MM-DD HH:MM:SS" -> "YYYY-MM-DDTHH:MM:SS"
      final dateStr = message.createdAt.replaceAll(' ', 'T');
      final date = DateTime.parse(dateStr);
      final difference = DateTime.now().difference(date);
      return difference.inHours < 48;
    } catch (_) {
      return false;
    }
  }
}
