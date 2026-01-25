import 'dart:io';

import 'package:lets_talk/app/router/arg/router_args.dart';

class MediaPreviewArgs extends RouterArgs {
  final File file;

  const MediaPreviewArgs({
    required this.file,
  });
}