import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
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
    return Container(
      height: context.size!.height * 0.65,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8),
                  child: GlassButton(icon: Icons.close, onTap: context.pop),
                ),
              ),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: Container()),
            ],
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