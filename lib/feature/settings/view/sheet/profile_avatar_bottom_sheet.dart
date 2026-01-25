import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/widget/c_bottom_sheet.dart';
import 'package:lets_talk/common/widget/gallery/phone_gallery.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/photo_editor_page.dart';

class ProfileAvatarBottomSheet extends StatelessWidget {

  const ProfileAvatarBottomSheet({super.key});

  Future<void> _onGetMediaFile(BuildContext context, File file) async {
    // Close the bottom sheet first
    context.pop();
    
    // Open photo editor with the selected file
    final editedFile = await context.push<File>(
      Routes.photoEditor.path,
      extra: PhotoEditorPage(imageFile: file),
    );
    
    if (editedFile != null && context.mounted) {
      // Upload the edited avatar
      getIt<ProfileBloc>().add(ProfileUpdateAvatarEvent(editedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CBottomSheet(
      children: [
        Expanded(
          child: PhoneGallery(
            onGetMediaFile: (file) => _onGetMediaFile(context, file),
          ),
        )
      ],
    );
  }

}