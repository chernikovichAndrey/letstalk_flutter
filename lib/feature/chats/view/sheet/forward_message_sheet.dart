import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_slivers.dart';

class ForwardMessageSheet extends StatelessWidget {
  const ForwardMessageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocProvider.value(
      value: getIt<ChatsBloc>(),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: appColors.backgroundColor,
            elevation: 0,
            leadingWidth: 56,
            leading: IconButton(
              onPressed: context.pop,
              icon: Icon(
                Icons.close,
                size: 24,
                color: appColors.glassForeground,
              ),
            ),
            actions: const [SizedBox(width: 56)],
            title: Text(
              context.s.forward,
              style: AppTypography.textLgMedium.copyWith(
                color: appColors.glassForeground,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<ChatsBloc, ChatsState>(
            builder: (context, state) {
              if (state is ChatsLoading) {
                return const ChatListSkeleton();
              }
              final args = context.getArgsOrNull<ForwardMessageArgs>();
              return CustomScrollView(
                slivers: [
                  ChatSlivers(
                    forwardChatId: args?.chatId,
                    onSelectChat: (id) {
                      if (args != null) {
                        getIt<WebSocketService>().forwardMessage(
                          args.messageId,
                          id,
                        );
                        showSuccessToast(context.s.messageForwarded);
                        context.pop();
                      }
                    },
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: context.padding.bottom),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
