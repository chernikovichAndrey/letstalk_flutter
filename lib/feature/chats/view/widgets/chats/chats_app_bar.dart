import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_app_bar_action_button.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/remove_chat_bottom_sheet.dart';

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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BlocBuilder<ChatsBloc, ChatsState>(
                            builder: (context, state) {
                              if (state is ChatsLoaded && state.isSelectionMode) {
                                return Row(
                                  children: [
                                    GlassButton(
                                      icon: Icons.close,
                                      onTap: () => context
                                          .read<ChatsBloc>()
                                          .add(ChatsToggleSelectionMode()),
                                    ),
                                    if (state.selectedChatIds.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      GlassButton(
                                        icon: Icons.delete,
                                        onTap: () => RemoveChatBottomSheet(context),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              final hasChats = state is ChatsLoaded && state.chats.isNotEmpty;

                              return GlassButton(
                                icon: Icons.edit,
                                onTap: hasChats
                                    ? () => context
                                    .read<ChatsBloc>()
                                    .add(ChatsToggleSelectionMode())
                                    : () {},
                              );
                            },
                          )
                        ],
                      ),
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassButton(
                            icon: Icons.chat_bubble_outline,
                            onTap: () {
                              context.push(Routes.chatContacts.path);
                            },
                          )
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
    );
  }
}
