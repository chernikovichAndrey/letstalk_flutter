import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_input/pure_message_input.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_input/replay_preview.dart';

class MessageInput extends StatefulWidget {
  final ScrollController controller;

  const MessageInput({super.key, required this.controller});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  bool _showSendButton = false;
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final shouldShow = text.isNotEmpty;
    if (_showSendButton != shouldShow) {
      setState(() {
        _showSendButton = shouldShow;
      });
    }

    if (shouldShow) {
      if (!_isTyping) {
        _isTyping = true;
        context.read<ChatDetailsBloc>().add(ChatDetailsSendTyping(true));
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _isTyping = false;
        if (mounted) {
          context.read<ChatDetailsBloc>().add(ChatDetailsSendTyping(false));
        }
      });
    } else {
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        context.read<ChatDetailsBloc>().add(ChatDetailsSendTyping(false));
      }
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSendMessage(ChatDetailsState state, bool isEditing, {File? file}) {
    final text = _controller.text.trim();
    if (text.isNotEmpty || state.attachedMedia != null || file != null) {
      if (isEditing) {
        context.read<ChatDetailsBloc>().add(
          ChatDetailsEditMessage(state.messageToEdit!.id, text),
        );
      } else {
        context.read<ChatDetailsBloc>().add(
          ChatDetailsSendMessage(text, file: file),
        );
      }
      widget.controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _controller.clear();

      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        context.read<ChatDetailsBloc>().add(ChatDetailsSendTyping(false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return BlocConsumer<ChatDetailsBloc, ChatDetailsState>(
      listenWhen: (previous, current) =>
          previous.messageToEdit != current.messageToEdit,
      listener: (context, state) {
        if (state.messageToEdit != null) {
          _controller.text = state.messageToEdit!.text ?? '';
          _inputFocus.requestFocus();
        } else {
          _controller.clear();
        }
      },
      builder: (context, state) {
        final isEditing = state.messageToEdit != null;
        final hasAttachment = state.attachedMedia != null;
        final hasReply = state.replyMessage != null;
        final canSend = _showSendButton || hasAttachment;

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: appColors.glassBackground,
              padding: EdgeInsets.only(
                left: 8,
                right: 16,
                top: 8,
                bottom: context.padding.bottom + 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasReply) ReplayPreview(message: state.replyMessage!),
                  if (hasAttachment)
                    _buildAttachmentPreview(context, state.attachedMedia!),
                  PureMessageInput(
                    inputFocus: _inputFocus,
                    controller: _controller,
                    hintText: isEditing
                        ? context.s.edit
                        : context.s.messageInputHint,
                    showSendButton: canSend,
                    onSendMessage: () => _onSendMessage(state, isEditing),
                    leftAction: GlassButton(
                      size: 45,
                      iconSize: 30,
                      icon: isEditing ? Icons.close : Icons.attach_file,
                      onTap: () async {
                        if (isEditing) {
                          context.read<ChatDetailsBloc>().add(
                            ChatDetailsSetEditingMessage(null),
                          );
                        } else {
                          final file = await context.router.push(
                            Routes.chatAttachSheet.path,
                          );
                          if (context.mounted && file != null) {
                            _onSendMessage(
                              context.read<ChatDetailsBloc>().state,
                              false,
                              file: file as File,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //TODO: remove in future when parrallel upload will be added
  Widget _buildAttachmentPreview(BuildContext context, Media media) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              media.filename,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: () {
              context.read<ChatDetailsBloc>().add(
                ChatDetailsSetAttachedMedia(null),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
