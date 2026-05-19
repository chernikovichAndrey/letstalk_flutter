import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/media_viewer_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/media_viewer/network_image_viewer.dart';
import 'package:lets_talk/feature/chats/view/widgets/media_viewer/network_video_viewer.dart';

class MediaViewerSheet extends StatelessWidget {
  const MediaViewerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final args = context.getArgsOrNull<MediaViewerArgs>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: context.mediaSize.height * 0.92,
        child: Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: appColors.backgroundColor,
            elevation: 0,
            leadingWidth: 56,
            leading: IconButton(
              onPressed: context.pop,
              icon: Icon(
                Icons.close,
                size: 24,
                color: appColors.glassForeground,
              ),
            ),
            actions: const [SizedBox(width: 56)],
            centerTitle: true,
          ),
          body: args?.mediaType == 'image'
              ? NetworkImageViewer(imageUrl: args?.thumbnailUrl)
              : NetworkVideoViewer(videoUrl: args?.videoUrl),
        ),
      ),
    );
  }
}
