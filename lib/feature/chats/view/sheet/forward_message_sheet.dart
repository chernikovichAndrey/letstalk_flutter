import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_details/forward_message_hader.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/chat_slivers.dart';

class ForwardMessageSheet extends StatelessWidget {
  const ForwardMessageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ChatsBloc>(),
      child: Container(
        height: context.mediaSize.height * 0.92,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoading) {
              return Padding(
                padding: EdgeInsets.only(top: context.padding.top + 66),
                child: const ChatListSkeleton(),
              );
            }
            final args = context.getArgsOrNull<ForwardMessageArgs>();
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(padding: EdgeInsets.only(top: 60)),
                    ChatSlivers(
                      state: state,
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
                  ],
                ),
                const ForwardMessageHeader(),
              ],
            );
          },
        ),
      ),
    );
  }
}
