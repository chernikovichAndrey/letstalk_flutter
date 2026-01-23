import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_list_skeleton.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_slivers.dart';

class ForwardMessageSheet extends StatelessWidget {
  const ForwardMessageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatsBloc(ChatsRepositoryImpl())..add(ChatsLoad()),
      child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Scaffold(
            backgroundColor: context.appColors.surfaceSecondary,
            appBar: AppBar(
              backgroundColor: context.appColors.surfaceSecondary,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GlassButton(icon: Icons.close, onTap: context.pop),
              ),
              title: Text(
                context.s.newCall,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appColors.glassForeground,
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<ChatsBloc, ChatsState>(
                builder: (context, state) {
                  if (state is ChatsLoading) {
                    return Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 66),
                      child: const ChatListSkeleton(),
                    );
                  }
                  return CustomScrollView(
                    slivers: [
                      ChatSlivers(
                        state: state,
                        onSelectChat: (id) {
                          //TODO: forward message
                        },
                      )
                    ],
                  );
                }
            ),
          ),
      ),
    );
  }
}