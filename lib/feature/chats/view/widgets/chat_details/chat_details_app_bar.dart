import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
        child: Container(
          decoration: BoxDecoration(
            color: appColors.glassBackground,
            border: Border(
              bottom: BorderSide(color: appColors.divider, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _BackButton(iconColor: appColors.glassForeground),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: IntrinsicWidth(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () => context.push(Routes.chatInfoSheet.path),
                            child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
                              builder: (context, state) {
                                final hasSubtitle =
                                    state.typingUserIds.isNotEmpty ||
                                    (state.chat?.type == 'group' &&
                                        state.typingUserIds.isEmpty);

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      chatTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.textMdMedium.copyWith(
                                        color: appColors.glassForeground,
                                      ),
                                    ),
                                    if (hasSubtitle)
                                      Text(
                                        state.typingUserIds.isNotEmpty
                                            ? context.s.typing
                                            : context.s.participantsCount(
                                                state.chat?.memberInfo?.length ?? 1,
                                              ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.textXsRegular.copyWith(
                                          color: AppColors.grayLight,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Opacity(
                    opacity: isFavorites ? 0 : 1,
                    child: GestureDetector(
                      onTap: isFavorites
                          ? null
                          : () => context.push(Routes.chatInfoSheet.path),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: CAvatar(
                            radius: 18,
                            imageUrl: avatarUrl,
                            name: chatTitle,
                          ),
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

class _BackButton extends StatelessWidget {
  final Color iconColor;

  const _BackButton({required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.pop,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
