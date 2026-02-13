import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_forward.dart';
import 'package:video_player/video_player.dart';

class MessageVideoAttachThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final int messageId;
  final Message message;

  const MessageVideoAttachThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.messageId,
    required this.message,
  });

  @override
  State<MessageVideoAttachThumbnail> createState() => _MessageVideoAttachThumbnailState();
}

class _MessageVideoAttachThumbnailState extends State<MessageVideoAttachThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.thumbnailUrl),
        httpHeaders: {'Authorization': 'Bearer $token'},
      );

      await _controller!.initialize();
      await _controller!.seekTo(Duration.zero);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageForward(forwardedFrom: widget.message.forwardedFrom),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _hasError
                  ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Icon(Icons.videocam, color: Colors.white70, size: 20),
                    )
                  : _isInitialized
                      ? SizedBox(
                          width: 200,
                          height: 200,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
            ),
            BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
              builder: (context, state) {
                if (state.downloadingMessageId == widget.messageId) {
                  final progress = state.downloadProgress ?? 0.0;
                  final progressPercent = (progress * 100).toInt();
                  
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: state.downloadProgress,
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          if (progressPercent > 0)
                            Text(
                              '$progressPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
