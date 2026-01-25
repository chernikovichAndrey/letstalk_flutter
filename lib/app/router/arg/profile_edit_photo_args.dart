import 'dart:io';

import 'package:lets_talk/app/router/arg/router_args.dart';

class ProfileEditPhotoArgs extends RouterArgs {
  final File file;

  const ProfileEditPhotoArgs({
    required this.file,
  });
}