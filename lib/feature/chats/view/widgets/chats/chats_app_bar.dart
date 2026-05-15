import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chats_app_bar_leading.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chats_app_bar_new_chat_button.dart';

class ChatsAppBar extends StatelessWidget {
  const ChatsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark.withValues(alpha: 0.7)
        : AppColors.backgroundLight.withValues(alpha: 0.7);
    final titleColor = isDark ? AppColors.white : AppColors.messageDark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
        child: Container(
          color: bgColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: BlocBuilder<ChatsBloc, ChatsState>(
                        buildWhen: (prev, curr) {
                          if (prev is ChatsLoaded && curr is ChatsLoaded) {
                            return prev.isSelectionMode != curr.isSelectionMode ||
                                prev.selectedChatIds.length !=
                                    curr.selectedChatIds.length;
                          }
                          return prev.runtimeType != curr.runtimeType;
                        },
                        builder: (context, state) {
                          final title = _title(context, state);
                          return Text(
                            title,
                            style: AppTypography.headingXsMedium.copyWith(
                              color: titleColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: ChatsAppBarLeading(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ChatsAppBarNewChatButton(
                        onTap: () => context.push(Routes.chatContacts.path),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context, ChatsState state) {
    if (state is ChatsLoaded &&
        state.isSelectionMode &&
        state.selectedChatIds.isNotEmpty) {
      return state.selectedChatIds.length.toString();
    }
    return context.s.chats;
  }
}
