import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';

class CreateChatGroupAppBar extends StatelessWidget {
  final String? nextLabel;
  final VoidCallback? onPressNext;
  final bool isActionEnabled;

  const CreateChatGroupAppBar({
    super.key,
    this.nextLabel,
    this.onPressNext,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Stack(
            children: [
              const Positioned.fill(child: GlassAppBarBackground()),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GlassButton(
                              icon: Icons.arrow_back_ios_new,
                              onTap: context.pop,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          context.s.group,
                          style: TextStyle(
                            color: context.appColors.glassForeground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GlassButton(
                              label: nextLabel ?? context.s.next,
                              onTap: onPressNext ?? () => context.push(Routes.createChatGroup),
                              isEnabled: isActionEnabled,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
