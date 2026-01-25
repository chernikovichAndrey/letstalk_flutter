import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_bottom_sheet.dart';
import 'package:lets_talk/common/widget/gallery/phone_gallery.dart';

class ProfileAvatarBottomSheet extends StatelessWidget {

  const ProfileAvatarBottomSheet({super.key});

  void _onGetMediaFile(File file) {

  }

  @override
  Widget build(BuildContext context) {
    return CBottomSheet(
      children: [
        Expanded(
          child: PhoneGallery(onGetMediaFile: _onGetMediaFile),
        )
      ],
    );
  }

}