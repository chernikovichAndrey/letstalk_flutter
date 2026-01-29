import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_name_input.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_contact_item.dart';
import 'package:lets_talk/feature/chats/view/widgets/create_chat_group/create_chat_group_app_bar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/chats/domain/repository/chats_repository.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class CreateChatGroupPage extends StatefulWidget {
  const CreateChatGroupPage({super.key});

  @override
  State<CreateChatGroupPage> createState() => _CreateChatGroupPageState();
}

class _CreateChatGroupPageState extends State<CreateChatGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isCreating = false;

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
        .where((contact) => state.selectedContactIds.contains(contact.registeredUserId))
        .toList();
  }

  void _createGroupChat() {
    if (_isCreating) return;

    final contactsState = getIt<ContactsBloc>().state;
    if (contactsState is! ContactsLoaded) return;

    final profileState = getIt<ProfileBloc>().state;
    final userIds = contactsState.selectedContactIds.toList();

    if (profileState.user != null) {
      userIds.add(profileState.user!.id);
    }


    final title = _groupNameController.text.trim();
    if (title.isEmpty) {
      showErrorToast(context.s.enterGroupName);
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      getIt<ChatsBloc>().add(CreateChatGroup(userIds, title));
      context.replace(Routes.chats);
    } catch (e) {
      if (!mounted) return;
      showErrorToast(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
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
                      //TODO: upload group title
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
              isActionEnabled: _groupNameController.text.trim().isNotEmpty && !_isCreating,
              nextLabel: context.s.create,
              onPressNext: _createGroupChat,
            ),
          ],
        ),
      ),
    );
  }
}