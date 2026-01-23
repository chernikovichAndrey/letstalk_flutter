import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

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
    if (text.isNotEmpty) {
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GlassButton(
                    icon: isEditing ? Icons.close : Icons.attach_file,
                    onTap: () {
                      if (isEditing) {
                        context.read<ChatDetailsBloc>().add(
                          ChatDetailsSetEditingMessage(null),
                        );
                      } else {
                        //TODO: attach
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
                        suffixIcon: _showSendButton
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
            ),
          ),
        );
      },
    );
  }
}
