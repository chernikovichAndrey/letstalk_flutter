import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/common/widget/select_call_type_dialog.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class ChatDetailsAppBar extends StatelessWidget {
  final String chatTitle;
  final String? avatarUrl;
  final int? memberId;

  const ChatDetailsAppBar({
    super.key,
    required this.chatTitle,
    this.memberId,
    this.avatarUrl,
  });

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
            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassButton(
                      icon: Icons.arrow_back,
                      onTap: context.pop,
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
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
                          child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
                            builder: (context, state) {
                              return Center(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: chatTitle,
                                        style: TextStyle(
                                          color: baseColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (state.typingUserIds.isNotEmpty)
                                        TextSpan(
                                          text: '\n${context.s.typing}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      if (state.chat?.type == 'group' && state.typingUserIds.isEmpty)
                                        TextSpan(
                                          text: '\n${context.s.participantsCount(state.chat?.membersCount ?? 1)}',
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
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          //TODO: show chat info sheet
                        },
                        child: CAvatar(
                          radius: 25,
                          imageUrl: avatarUrl != null ? '${Env.baseUrl}uploads/$avatarUrl' : null,
                          name: chatTitle,
                        ),
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
