import 'package:photo_manager/photo_manager.dart';
import 'package:lets_talk/app/router/arg/router_args.dart'; // Если используете базовый класс

class MediaPreviewArgs extends RouterArgs {
  final AssetEntity asset;

  const MediaPreviewArgs({
    required this.asset,
  });
}