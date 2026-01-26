import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_name_input.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_contact_item.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_app_bar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class CreateChatGroupPage extends StatefulWidget {
  const CreateChatGroupPage({super.key});

  @override
  State<CreateChatGroupPage> createState() => _CreateChatGroupPageState();
}

class _CreateChatGroupPageState extends State<CreateChatGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  List<Contact> _getSelectedContacts(ContactsLoaded state) {
    return state.allContacts
        .where((contact) => state.selectedContactIds.contains(contact.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  CreateChatGroupNameInput(
                    groupNameController: _groupNameController,
                    onPressCamera: () {
                      //TODO
                      showWarningToast(context.s.notWorkingNow);
                    },
                    onClearInput: () {
                      setState(() {
                        _groupNameController.clear();
                      });
                    },
                  ),
                  Expanded(
                    child: BlocBuilder<ContactsBloc, ContactsState>(
                      builder: (context, state) {
                        if (state is ContactsLoaded) {
                          final selectedContacts = _getSelectedContacts(state);
                          
                          if (selectedContacts.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                            itemCount: selectedContacts.length,
                            itemBuilder: (context, index) {
                              final contact = selectedContacts[index];
                              return CreateChatGroupContactItem(contact: contact);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
            CreateChatGroupAppBar(
              isActionEnabled: _groupNameController.text.trim().isNotEmpty,
              nextLabel: context.s.create,
              onPressNext: () {
                // TODO: Create group action
              },
            ),
          ],
        ),
      ),
    );
  }
}