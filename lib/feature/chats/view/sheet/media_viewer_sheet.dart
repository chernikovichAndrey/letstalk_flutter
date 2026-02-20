import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/media_viewer_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/view/widgets/media_viewer/network_image_viewer.dart';
import 'package:lets_talk/feature/chats/view/widgets/media_viewer/network_video_viewer.dart';

class MediaViewerSheet extends StatelessWidget {
  const MediaViewerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final args = context.getArgsOrNull<MediaViewerArgs>();

    return Container(
      height: context.mediaSize.height * 0.92,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 34,
                    horizontal: 4,
                  ),
                  child: args?.mediaType == 'image'
                      ? NetworkImageViewer(imageUrl: args?.thumbnailUrl)
                      : NetworkVideoViewer(videoUrl: args?.videoUrl),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassButton(icon: Icons.close, onTap: context.pop),
                    SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
