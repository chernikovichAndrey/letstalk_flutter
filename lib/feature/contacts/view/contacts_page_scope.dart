import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page.dart';

class ContactsPageScope extends StatelessWidget {
  const ContactsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactsBloc>(
      create: (_) => getIt<ContactsBloc>()..add(ContactsSyncPhoneContacts()),
      child: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsChatCreated) {
            context.go(
              '${Routes.chats.path}/${Routes.chatDetails.path}',
              extra: ChatDetailsArgs(chatId: state.chatId),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: const ContactsPage(),
        ),
      ),
    );
  }
}
