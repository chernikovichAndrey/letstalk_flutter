import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/sheet/widgets/chat_contact_sheet_action.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class ChatContactsSheet extends StatelessWidget {
  const ChatContactsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsLoad()),
      child: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsChatCreated) {
            context.go(
              '${Routes.chats.path}/${Routes.chatDetails.path}',
              extra: ChatDetailsArgs(chatId: state.chatId),
            );
          }
        },
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
                context.s.writeMessage,
                style: AppTypography.textLgMedium.copyWith(
                  color: appColors.glassForeground,
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                if (state is ContactsLoading ||
                    state is ContactsActionInProgress) {
                  return const ContactsSceleton();
                }
                return CustomScrollView(
                  slivers: [
                    ContactsSlivers(
                      state: state,
                      isRegisteredOnly: true,
                      children: [
                        ChatContactSheetAction(
                          icon: Icons.group_outlined,
                          title: context.s.createGroup,
                          onTap: () =>
                              context.push(Routes.selectContactsFroGroup.path),
                        ),
                        ChatContactSheetAction(
                          icon: Icons.person_add_outlined,
                          title: context.s.createContact,
                          onTap: () async {
                            await context.push(Routes.createContact.path);
                            if (context.mounted) {
                              context.read<ContactsBloc>().add(
                                ContactsRefresh(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
