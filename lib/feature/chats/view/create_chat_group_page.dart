import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_app_bar.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class CreateChatGroupPage extends StatelessWidget {
  const CreateChatGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: context.appColors.surfaceSecondary,
        //   elevation: 0,
        //   leading: Padding(
        //     padding: const EdgeInsets.all(8),
        //     child: GlassButton(icon: Icons.arrow_back_ios_new, onTap: context.pop),
        //   ),
        //   title: Text(
        //     context.s.writeMessage,
        //     style: context.text.titleMedium?.copyWith(
        //       fontWeight: FontWeight.bold,
        //       color: context.appColors.glassForeground,
        //     ),
        //   ),
        //   centerTitle: true,
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.all(8),
        //       child: GlassButton(
        //         icon: Icons.check,
        //         label: 'Далее',
        //         onTap: () {
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        body: Stack(
          children: [
            BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                if (state is ContactsLoading ||
                    state is ContactsActionInProgress) {
                  return const ContactsSceleton();
                }
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: context.padding.top + 66),
                    ),
                    ContactsSlivers(state: state, isRegisteredOnly: true),
                  ],
                );
              },
            ),
            const CreateChatGroupAppBar(),
          ],
        ),
      ),
    );
  }
}
