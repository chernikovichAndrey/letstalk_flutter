import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/feature/contacts/data/repository/add_contact_repository_impl.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/view/create_contact_page.dart';

class CreateContactPageScope extends StatelessWidget {
  const CreateContactPageScope({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddContactBloc(AddContactRepositoryImpl()),
      child: const CreateContactPage(),
    );
  }
}