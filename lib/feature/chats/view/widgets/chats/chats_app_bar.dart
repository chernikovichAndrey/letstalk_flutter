import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
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
            const Positioned.fill(child: GlassAppBarBackground()),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BlocBuilder<ChatsBloc, ChatsState>(
                            builder: (context, state) {
                              if (state is ChatsLoaded &&
                                  state.isSelectionMode) {
                                return Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => context
                                          .read<ChatsBloc>()
                                          .add(ChatsToggleSelectionMode()),
                                      icon: Icon(Icons.close),
                                    ),
                                    if (state.selectedChatIds.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () =>
                                            RemoveChatBottomSheet(context),
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              final hasChats =
                                  state is ChatsLoaded &&
                                  state.chats.isNotEmpty;

                              return IconButton(
                                onPressed: hasChats
                                    ? () => context.read<ChatsBloc>().add(
                                        ChatsToggleSelectionMode(),
                                      )
                                    : () {},
                                icon: Icon(Icons.edit),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        context.s.chats,
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline),
                            onPressed: () => context.push(Routes.chatContacts.path),
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
    );
  }
}
