import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final Function(AssetEntity asset) onTapAsset;

  const AssetThumbnail({
    super.key,
    required this.asset,
    required this.onTapAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapAsset(asset),
      child: FutureBuilder<Uint8List?>(
        future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return Container(color: Colors.grey[900]);
        },
      ),
    );
  }
}
