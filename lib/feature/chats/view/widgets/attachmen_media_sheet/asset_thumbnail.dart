import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/media_perview_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  const AssetThumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        context.push(Routes.fullScreenMedia, args: MediaPreviewArgs(asset: asset));
      },
      child: FutureBuilder<Uint8List?>(
        future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
          return Container(color: Colors.grey[900]);
        },
      ),
    );
  }
}
