 import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/profile_edit_photo_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/widget/c_bottom_sheet.dart';
import 'package:lets_talk/common/widget/gallery/phone_gallery.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class ChatAvatarBottomSheet extends StatelessWidget {
  const ChatAvatarBottomSheet({super.key});

  Future<void> _onGetMediaFile(BuildContext context, File file) async {
    final editedFile = await context.push<File>(
      Routes.photoEditor.path,
      extra: ProfileEditPhotoArgs(file: file),
    );

    if (editedFile != null && context.mounted) {
      getIt<ChatDetailsBloc>().add(UpdateChatAvatar(editedFile));
      context.pop();
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