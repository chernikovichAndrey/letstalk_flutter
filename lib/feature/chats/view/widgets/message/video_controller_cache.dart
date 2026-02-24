import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoControllerCache {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, Future<VideoPlayerController?>> _futures = {};

  /// Returns already-initialized controller synchronously, or null if not ready.
  VideoPlayerController? getSync(String url) => _controllers[url];

  /// Returns a future that resolves to the initialized controller.
  /// On subsequent calls for the same URL, returns the same future.
  Future<VideoPlayerController?> getOrCreate(String url, String token) {
    if (_futures.containsKey(url)) return _futures[url]!;

    final future = _initController(url, token);
    _futures[url] = future;
    return future;
  }

  Future<VideoPlayerController?> _initController(
    String url,
    String token,
  ) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {'Authorization': 'Bearer $token'},
    );
    _controllers[url] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);
      return controller;
    } catch (_) {
      _controllers.remove(url);
      _futures.remove(url);
      controller.dispose();
      return null;
    }
  }

  void disposeAll() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _futures.clear();
  }
}

class VideoControllerCacheProvider extends InheritedWidget {
  final VideoControllerCache cache;
  final ScrollController scrollController;

  const VideoControllerCacheProvider({
    super.key,
    required this.cache,
    required this.scrollController,
    required super.child,
  });

  static VideoControllerCacheProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoControllerCacheProvider>()!;
  }

  @override
  bool updateShouldNotify(VideoControllerCacheProvider oldWidget) =>
      cache != oldWidget.cache ||
      scrollController != oldWidget.scrollController;
}
