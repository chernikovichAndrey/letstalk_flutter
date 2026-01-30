import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';

class ChatInfoAppBar extends StatelessWidget {
  const ChatInfoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassButton(icon: Icons.close, onTap: context.pop),
              // GlassButton(icon: Icons.edit, onTap: () {}),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}