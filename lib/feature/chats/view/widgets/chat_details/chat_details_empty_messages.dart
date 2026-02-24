import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';

class ChatDetailsEmptyMessages extends StatelessWidget {
  const ChatDetailsEmptyMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: context.appColors.secondaryBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
            builder: (context, state) {
              final text = state.chat?.role == 'admin'
                  ? context.s.chatCreatedByYou
                  : context.s.chatInvited;
              return Text(
                state.chat?.type == 'favorites' ? context.s.favoritesEmptyHint : text,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              );
            },
          ),
        ),
      ),
    );
  }
}
