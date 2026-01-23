import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/attachment_bottom_tab_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/files_tab.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/gallery_tab.dart';

class AttachmentBottomSheet extends StatefulWidget {
  const AttachmentBottomSheet({super.key});

  @override
  State<AttachmentBottomSheet> createState() => _AttachmentBottomSheetState();
}

class _AttachmentBottomSheetState extends State<AttachmentBottomSheet>
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

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: appColors.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GalleryTab(),
                FilesTab(),
              ],
            ),
          ),
          AttachmentBottomTabBar(controller: _tabController),
        ],
      ),
    );
  }
}