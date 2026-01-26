import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsPageScope extends StatefulWidget {
  const ContactsPageScope({super.key});

  @override
  State<ContactsPageScope> createState() => _ContactsPageScopeState();
}

class _ContactsPageScopeState extends State<ContactsPageScope> {
  SharedPreferences? _prefs;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeContacts();
  }

  Future<void> _initializeContacts() async {
    _prefs = await SharedPreferences.getInstance();
    final contactsSynced = _prefs!.getBool('contacts_synced_first_time') ?? false;
    
    final bloc = getIt<ContactsBloc>();
    bloc.add(
      !contactsSynced ? ContactsSyncPhoneContacts() : ContactsLoad()
    );
    
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _prefs == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final contactsSynced = _prefs!.getBool('contacts_synced_first_time') ?? false;

    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsLoaded && !contactsSynced) {
            _prefs!.setBool('contacts_synced_first_time', true);
          }
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
