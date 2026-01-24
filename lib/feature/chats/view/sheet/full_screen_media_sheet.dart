import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/media_perview_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/message_input/pure_message_input.dart';

class FullScreenMediaSheet extends StatefulWidget {
  const FullScreenMediaSheet({super.key});

  @override
  State<FullScreenMediaSheet> createState() => _FullScreenMediaSheetState();
}

class _FullScreenMediaSheetState extends State<FullScreenMediaSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _typingTimer;
  bool _isTyping = false;
  File? _file;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadFile();
  }

  Future<void> _loadFile() async {
    final args = context.getArgsOrNull<MediaPreviewArgs>();
    final file = await args!.asset.file;
    if (mounted) {
      setState(() {
        _file = file;
        _isLoading = false;
      });
    }
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final shouldShow = text.isNotEmpty;

    if (shouldShow) {
      if (!_isTyping) {
        _isTyping = true;
        getIt<ChatDetailsBloc>().add(ChatDetailsSendTyping(true));
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _isTyping = false;
        if (mounted) {
          getIt<ChatDetailsBloc>().add(ChatDetailsSendTyping(false));
        }
      });
    } else {
      if (_isTyping) {
        _isTyping = false;
        _typingTimer?.cancel();
        getIt<ChatDetailsBloc>().add(ChatDetailsSendTyping(false));
      }
    }
  }

  void onSendMessage() {
    final text = _controller.text.trim();

    if (_file == null || _isSending || text.isEmpty) return;
    setState(() {
      _isSending = true;
    });
    getIt<ChatDetailsBloc>().add(ChatDetailsSendMedia(_file!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatDetailsBloc, ChatDetailsState>(
      bloc: getIt<ChatDetailsBloc>(),
      listener: (context, state) {
        if (_isSending) {
          if (state.status == ChatDetailsStatus.failure) {
            setState(() {
              _isSending = false;
            });
          } else if (state.attachedMedia != null) {
            getIt<ChatDetailsBloc>().add(
              ChatDetailsSendMessage(_controller.text!),
            );
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: context.appColors.surfaceSecondary,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 70,
                bottom: 120,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  width: double.infinity,
                  decoration: _file != null
                      ? BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_file!),
                      fit: BoxFit.contain,
                    ),
                  )
                      : null,
                  child: (_isLoading || _isSending)
                      ? const Center(child: CircularProgressIndicator())
                      : null,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: GlassButton(icon: Icons.arrow_back, onTap: context.pop),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 40,
                top: 0,
                child: PureMessageInput(
                  controller: _controller,
                  showSendButton: true,
                  onSendMessage: onSendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
