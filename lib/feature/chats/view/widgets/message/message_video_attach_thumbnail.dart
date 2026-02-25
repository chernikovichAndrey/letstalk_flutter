import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/chats/data/model/message_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/message_forward.dart';
import 'package:lets_talk/feature/chats/view/widgets/message/video_controller_cache.dart';
import 'package:video_player/video_player.dart';

class MessageVideoAttachThumbnail extends StatefulWidget {
  final int messageId;
  final Message message;

  const MessageVideoAttachThumbnail({
    super.key,
    required this.messageId,
    required this.message,
  });

  @override
  State<MessageVideoAttachThumbnail> createState() =>
      _MessageVideoAttachThumbnailState();
}

class _MessageVideoAttachThumbnailState
    extends State<MessageVideoAttachThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVisible = false;
  ScrollController? _scrollController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  String? get _videoUrl {
    final url = widget.message.media?.videoUrl;
    return (url != null && url.isNotEmpty) ? url : null;
  }

  bool get _isProcessing => widget.message.media?.status == 'processing';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = VideoControllerCacheProvider.of(context);
    if (_scrollController != provider.scrollController) {
      _scrollController?.removeListener(_checkVisibility);
      _scrollController = provider.scrollController;
      _scrollController!.addListener(_checkVisibility);
    }
    if (!_initialized) {
      _initialized = true;
      if (!_isProcessing && _videoUrl != null) {
        _attachController();
      }
    }
  }

  @override
  void didUpdateWidget(MessageVideoAttachThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasProcessing = oldWidget.message.media?.status == 'processing';
    if (wasProcessing && !_isProcessing && _videoUrl != null && !_isInitialized) {
      _attachController();
    }
  }

  Future<void> _attachController() async {
    final url = _videoUrl;
    if (url == null) return;

    final provider = VideoControllerCacheProvider.of(context);
    final token = (context.read<AuthBloc>().state as AuthAuthenticated).token;

    // Use already-initialized controller immediately if available.
    final cached = provider.cache.getSync(url);
    if (cached != null && cached.value.isInitialized) {
      if (mounted) {
        setState(() {
          _controller = cached;
          _isInitialized = true;
        });
        _scheduleVisibilityCheck();
      }
      return;
    }

    // Otherwise wait for initialization (first load or still initializing).
    final controller = await provider.cache.getOrCreate(url, token ?? '');
    if (!mounted) return;

    if (controller != null) {
      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
      _scheduleVisibilityCheck();
    } else {
      setState(() => _hasError = true);
    }
  }

  void _scheduleVisibilityCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final position = renderObject.localToGlobal(Offset.zero);
    final widgetTop = position.dy;
    final widgetBottom = position.dy + renderObject.size.height;

    final isVisible = widgetTop < screenHeight && widgetBottom > 0;

    if (isVisible == _isVisible) return;
    _isVisible = isVisible;

    if (isVisible) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_checkVisibility);
    // Pause but do NOT dispose — controller lives in the cache.
    _controller?.pause();
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
              child: _isProcessing
                  ? Container(
                      width: 200,
                      height: 200,
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : _hasError
                  ? Container(
                      width: 200,
                      height: 200,
                      color: Colors.black,
                      child: const Icon(
                        Icons.videocam_off,
                        color: Colors.white70,
                        size: 20,
                      ),
                    )
                  : _isInitialized
                  ? Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                        maxHeight: 400,
                      ),
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
                      child: Center(child: CircularProgressIndicator()),
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
                return const SizedBox();
              },
            ),
          ],
        ),
      ],
    );
  }
}
