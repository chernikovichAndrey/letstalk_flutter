import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/attachment_bottom_sheet.dart';


class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

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

  void _onSendMessage(ChatDetailsState state, bool isEditing) {
    final text = _controller.text.trim();
    if (text.isNotEmpty || state.attachedMedia != null) {
      if (isEditing) {
        context.read<ChatDetailsBloc>().add(
          ChatDetailsEditMessage(
            state.messageToEdit!.id,
            text,
          ),
        );
      } else {
        context.read<ChatDetailsBloc>().add(
          ChatDetailsSendMessage(text),
        );
      }
      _controller.clear();

      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        context.read<ChatDetailsBloc>().add(
          ChatDetailsSendTyping(false),
        );
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
        // We rely on _showSendButton for text changes, but for attachment we use state.
        
        // We need to determine if send button should be shown.
        // It should be shown if _showSendButton (text > 0) OR hasAttachment.
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
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasAttachment)
                    _buildAttachmentPreview(context, state.attachedMedia!),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GlassButton(
                        icon: isEditing ? Icons.close : Icons.attach_file,
                        onTap: () async {
                          if (isEditing) {
                            context.read<ChatDetailsBloc>().add(
                              ChatDetailsSetEditingMessage(null),
                            );
                          } else {
                            final file = await Navigator.of(context).push(
                                ModalBottomSheetRoute(
                                  builder: (_) => const AttachmentBottomSheet(),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                )
                            );
                            if (context.mounted && file != null) {
                              context.read<ChatDetailsBloc>().add(
                                ChatDetailsSendMedia(file),
                              );
                            }
                          }
                        }
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          focusNode: _inputFocus,
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: isEditing
                                ? context.s.edit
                                : context.s.messageInputHint,
                            filled: true,
                            fillColor: appColors.inputSecondaryFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            suffixIcon: canSend
                                ? IconButton(
                                    onPressed: () => _onSendMessage(state, isEditing),
                                    icon: Icon(Icons.send),
                                    color: appColors.telegramBlue,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentPreview(BuildContext context, Media media) {
    final isImage = media.type == 'image';
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isImage && media.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                headers: {'Authorization': 'Bearer ${token}'},
                media.thumbnailUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.white70, size: 20),
              ),
            )
          else
            const Icon(Icons.attach_file, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
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
