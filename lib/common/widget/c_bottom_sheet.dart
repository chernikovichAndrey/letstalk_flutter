import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

import 'glass_button.dart';

class CBottomSheet extends StatelessWidget {
  final List<Widget> children;

  const CBottomSheet({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaSize.height * 0.65,
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
          ...children,
        ],
      ),
    );
  }
}