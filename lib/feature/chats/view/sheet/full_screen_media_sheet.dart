import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/media_perview_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/full_screen_media_sheet/image_preview.dart';
import 'package:lets_talk/feature/chats/view/widgets/full_screen_media_sheet/video_preview.dart';
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
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadFile();
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFile() async {
    final args = context.getArgsOrNull<MediaPreviewArgs>();
    final file = args!.file;
    
    final extension = file.path.split('.').last.toLowerCase();
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm', 'm4v'];
    _isVideo = videoExtensions.contains(extension);

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
    if (_file == null || _isSending) return;
    setState(() {
      _isSending = true;
    });
    getIt<ChatDetailsBloc>().add(
      ChatDetailsSendMessage(_controller.text, file: _file),
    );
    // Close full screen media sheet
    context.pop();
    // Close attachment bottom sheet
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocListener<ChatDetailsBloc, ChatDetailsState>(
      bloc: getIt<ChatDetailsBloc>(),
      listener: (context, state) {
        if (_isSending && state.status == ChatDetailsStatus.failure) {
          setState(() {
            _isSending = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: appColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: appColors.backgroundColor,
          elevation: 0,
          leadingWidth: 56,
          leading: IconButton(
            onPressed: context.pop,
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: appColors.glassForeground,
            ),
          ),
          actions: const [SizedBox(width: 56)],
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 120,
                left: 0,
                right: 0,
                child: (_isLoading || _isSending)
                    ? const Center(child: CircularProgressIndicator())
                    : _isVideo
                        ? VideoPreview(file: _file!)
                        : ImagePreview(file: _file),
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
