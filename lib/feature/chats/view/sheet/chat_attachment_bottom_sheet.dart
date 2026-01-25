import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/arg/media_perview_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/widget/c_bottom_sheet.dart';
import 'package:lets_talk/common/widget/gallery/phone_gallery.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/attachment_bottom_tab_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/files_tab.dart';

class ChatAttachmentBottomSheet extends StatefulWidget {
  const ChatAttachmentBottomSheet({super.key});

  @override
  State<ChatAttachmentBottomSheet> createState() => _ChatAttachmentBottomSheetState();
}

class _ChatAttachmentBottomSheetState extends State<ChatAttachmentBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onGetMediaFile(File file) async {
    context.push(
      Routes.fullScreenMedia,
      args: MediaPreviewArgs(file: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CBottomSheet(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PhoneGallery(onGetMediaFile: onGetMediaFile),
              FilesTab(),
            ],
          ),
        ),
        AttachmentBottomTabBar(controller: _tabController),
      ],
    );
  }
}