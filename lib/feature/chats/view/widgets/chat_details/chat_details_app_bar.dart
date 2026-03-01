import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class ChatDetailsAppBar extends StatelessWidget {
  final String chatTitle;
  final String? avatarUrl;
  final int? memberId;
  final bool isFavorites;

  const ChatDetailsAppBar({
    super.key,
    required this.chatTitle,
    required this.isFavorites,
    this.memberId,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = appColors.glassForeground;
    final isDark = context.theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.72);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: Icon(Icons.arrow_back_ios, color: context.appColors.telegramBlue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: IntrinsicWidth(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              context.push(Routes.chatInfoSheet.path);
                            },
                            child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
                              builder: (context, state) {
                                return Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Text(
                                            chatTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: baseColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (state.typingUserIds.isNotEmpty)
                                          TextSpan(
                                            text: '\n${context.s.typing}',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        if (state.chat?.type == 'group' &&
                                            state.typingUserIds.isEmpty)
                                          TextSpan(
                                            text: '\n${context.s.participantsCount(state.chat?.memberInfo?.length ?? 1)}',
                                            style: TextStyle(
                                              color: baseColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: isFavorites ? 0 : 1,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (!isFavorites) {
                            context.push(Routes.chatInfoSheet.path);
                          }
                        },
                        child: CAvatar(
                          radius: 20,
                          imageUrl: avatarUrl,
                          name: chatTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
