import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_bubble.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_menu.dart';

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
        pageBuilder: (context, _, __) => BlocProvider<ChatDetailsBloc>.value(
          value: getIt(),
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
  late bool _isCopyVisible;
  late bool _isDownloadVisible;

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

    setState(() {
      _isCopyVisible = widget.message.text != null && widget.message.text!.isNotEmpty;
      _isDownloadVisible = widget.message.messageType == 'image' &&
          widget.message.media != null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _canEdit(Message message) {
    if (!widget.isMe) return false;
    if (message.text == null || message.text!.isEmpty) return false;

    try {
      final date = DateTime.parse('${message.createdAt}Z').toLocal();
      final difference = DateTime.now().difference(date);
      return difference.inHours < 48;
    } catch (_) {
      return false;
    }
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
        ChatDetailsSetEditingMessage(widget.message),
      );
      if (context.mounted) {
        context.pop();
      }
    }
  }

  void _onForwardMessage() {
    context.pop();
    context.push(
      Routes.forwardMessage,
      args: ForwardMessageArgs(
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

  void _onDownloadImage() {
    final media = widget.message.media;
    if (media == null) return;

    final bloc = context.read<ChatDetailsBloc>();
    final messageId = widget.message.id;
    final downloadUrl = media.downloadUrl;
    final filename = media.filename;

    if (context.mounted) {
      context.pop();
    }

    bloc.add(
      SaveImageToGallery(
        imageUrl: downloadUrl,
        filename: filename,
        messageId: messageId,
      ),
    );
  }

  void _onReply() {
    context.read<ChatDetailsBloc>().add(
      ChatDetailsReplyToMessage(widget.message),
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
                              onCopy: _isCopyVisible ? _onCopyMessage : null,
                              onReply: _onReply,
                              onEdit: _onEditMessage,
                              onForward: _onForwardMessage,
                              onDelete: _onDeleteMessage,
                              onDownload: _isDownloadVisible
                                  ? _onDownloadImage
                                  : null,
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
}
