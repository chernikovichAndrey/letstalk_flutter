import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/contacts/data/repository/contacts_repository_impl.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/contacts_page.dart';

class ContactsPageScope extends StatelessWidget {
  const ContactsPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactsBloc(ContactsRepositoryImpl())..add(ContactsLoad()),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: const ContactsPage(),
      ),
    );
  }
}