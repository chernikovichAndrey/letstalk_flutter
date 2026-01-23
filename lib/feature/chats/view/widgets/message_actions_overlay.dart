import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
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
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) =>
            MessageActionsOverlay(message: message, isMe: isMe),
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
                            // Add padding at top to allow scroll down
                            // Message Bubble
                            IgnorePointer(
                              child: MessageBubble(
                                message: widget.message,
                                isMe: widget.isMe,
                              ),
                            ),
                            const SizedBox(height: 8),
                            MessageMenu(isMe: widget.isMe),
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
}
