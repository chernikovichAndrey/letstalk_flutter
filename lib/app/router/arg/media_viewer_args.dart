import 'package:lets_talk/app/router/arg/router_args.dart';

class MediaViewerArgs extends RouterArgs {
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? thumbnailUrl;

  const MediaViewerArgs({
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
  });
}
