import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';

class ChatsAppBar extends StatelessWidget {
  const ChatsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = appColors.glassForeground;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Stack(
          children: [
            const Positioned.fill(
              child: GlassAppBarBackground(),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassButton(
                      icon: Icons.edit,
                      onTap: () {},
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 50,
                            decoration: BoxDecoration(
                              color: appColors.glassButtonBackground,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                context.s.chats,
                                style: TextStyle(
                                  color: baseColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GlassButton(
                      icon: Icons.chat_bubble_outline,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
