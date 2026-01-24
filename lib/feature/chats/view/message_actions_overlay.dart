import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/app/router/arg/message_actions_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_bubble.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_menu.dart';

class MessageActionsOverlay extends StatefulWidget {
  const MessageActionsOverlay({super.key});

  @override
  State<MessageActionsOverlay> createState() => _MessageActionsOverlayState();
}

class _MessageActionsOverlayState extends State<MessageActionsOverlay> {
  late Message _message;
  late bool _isMe;
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
    final args = context.getArgsOrNull<MessageActionsArgs>();
    setState(() {
      _message = args!.message;
      _isMe = args.isMe;
      _isCopyVisible = args.message.text != null && args.message.text!.isNotEmpty;
      _isDownloadVisible = args.message.messageType == 'image' &&
          args.message.media != null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _canEdit(Message message) {
    if (!_isMe) return false;
    if (message.text == null || message.text!.isEmpty) return false;

    try {
      final dateStr = message.createdAt.replaceAll(' ', 'T');
      final date = DateTime.parse(dateStr);
      final difference = DateTime.now().difference(date);
      return difference.inHours < 48;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onCopyMessage() async {
    await Clipboard.setData(
      ClipboardData(
        text: _message.text ?? '',
      ),
    );
    if (context.mounted) {
      context.pop();
    }
  }

  void _onEditMessage() {
    if (_canEdit(_message)) {
      context.read<ChatDetailsBloc>().add(
        ChatDetailsSetEditingMessage(_message),
      );
      if (context.mounted) {
        context.pop();
      }
    }
  }

  void _onForwardMessage() {
    context.pop();
    context.push(
      Routes.forwardMessage.path as Routes,
      args: ForwardMessageArgs(
        messageId: _message.id,
        chatId: _message.chatId,
      ),
    );
  }

  void _onDeleteMessage() {
    context.read<ChatDetailsBloc>().add(
      ChatDetailsDeleteMessage(_message.id),
    );
    if (context.mounted) {
      context.pop();
    }
  }

  void _onDownloadImage() {
    final media = _message.media;
    if (media == null) return;

    final bloc = context.read<ChatDetailsBloc>();
    final messageId = _message.id;
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
      ChatDetailsReplyToMessage(_message),
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
                                message: _message,
                                isMe: _isMe,
                              ),
                            ),
                            const SizedBox(height: 8),
                            MessageMenu(
                              isMe: _isMe,
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
