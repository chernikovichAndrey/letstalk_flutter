import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/chat_details_page.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatDetailsPageScope extends StatefulWidget {
  final int chatId;

  const ChatDetailsPageScope({super.key, required this.chatId});

  @override
  State<ChatDetailsPageScope> createState() => _ChatDetailsPageScopeState();
}

class _ChatDetailsPageScopeState extends State<ChatDetailsPageScope> {
  @override
  void initState() {
    super.initState();
    final user = getIt<ProfileBloc>().state.user;
    if (user != null) {
      getIt<ChatDetailsBloc>().add(ChatDetailsLoad(widget.chatId, user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      bloc: getIt<ProfileBloc>(),
      listenWhen: (prev, curr) => prev.user != curr.user && curr.user != null,
      listener: (context, state) {
        getIt<ChatDetailsBloc>().add(ChatDetailsLoad(widget.chatId, state.user!));
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: getIt<ProfileBloc>(),
        buildWhen: (prev, curr) => (prev.user == null) != (curr.user == null),
        builder: (context, state) {
          if (state.user != null) {
            return BlocProvider<ChatDetailsBloc>.value(
              value: getIt(),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ChatDetailsPage(chatId: widget.chatId),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
