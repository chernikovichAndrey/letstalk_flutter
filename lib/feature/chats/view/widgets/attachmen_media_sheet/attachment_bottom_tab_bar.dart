import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class AttachmentBottomTabBar extends StatelessWidget {
  final TabController controller;

  const AttachmentBottomTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: context.padding.bottom + 16,
        top: 16,
      ),
      child: Center(
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: controller,
            indicator: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: context.s.gallery),
              Tab(text: context.s.file),
            ],
          ),
        ),
      ),
    );
  }
}