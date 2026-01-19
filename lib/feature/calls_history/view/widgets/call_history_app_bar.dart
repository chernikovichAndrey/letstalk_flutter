import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class CallHistoryAppBar extends StatelessWidget {
  const CallHistoryAppBar({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    GlassButton(
                      icon: Icons.edit,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: appColors.glassButtonBackground,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Theme.of(context).colorScheme.onSurface,
                          unselectedLabelColor: baseColor.withValues(alpha: 0.6),
                          tabs: [
                            Tab(
                              child: Text(
                                context.s.allCalls,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Tab(
                              child: Text(
                                context.s.missedCalls,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassButton(
                      icon: Icons.call,
                      onTap: () {
                        context.read<CallBloc>().add(CallInitiated(targetUserId: 22));
                      },
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
