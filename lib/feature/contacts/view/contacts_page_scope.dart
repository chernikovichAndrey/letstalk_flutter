import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/feature/chats/data/repository/chats_repository_impl.dart';
import 'package:lets_talk/feature/contacts/data/repository/contacts_repository_impl.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsPageScope extends StatelessWidget {
  const ContactsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final prefs = snapshot.data!;
        final contactsSynced =
            prefs.getBool('contacts_synced_first_time') ?? false;

        return BlocProvider(
          create: (context) {
            final bloc = ContactsBloc(
              ContactsRepositoryImpl(),
              ChatsRepositoryImpl(),
            );
            if (!contactsSynced) {
              bloc.add(ContactsSyncPhoneContacts());
            } else {
              bloc.add(ContactsLoad());
            }
            return bloc;
          },
          child: BlocListener<ContactsBloc, ContactsState>(
            listener: (context, state) {
              if (state is ContactsLoaded && !contactsSynced) {
                prefs.setBool('contacts_synced_first_time', true);
              }
              if (state is ContactsChatCreated) {
                context.go(
                  '${Routes.chats.path}/${Routes.chatDetails.path}'
                      .replaceFirst(':id', state.chatId.toString()),
                );
              }
            },
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: const ContactsPage(),
            ),
          ),
        );
      },
    );
  }
}
