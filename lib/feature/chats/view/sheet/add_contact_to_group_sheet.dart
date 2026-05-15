import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/add_contact_to_group/add_contact_to_group_app_bar.dart';
import 'package:lets_talk/feature/chats/view/widgets/add_contact_to_group/add_contact_to_group_list.dart';
import 'package:lets_talk/feature/chats/view/widgets/add_contact_to_group/add_contact_to_group_search_field.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class AddContactToGroupSheet extends StatefulWidget {
  const AddContactToGroupSheet({super.key});

  @override
  State<AddContactToGroupSheet> createState() => _AddContactToGroupSheetState();
}

class _AddContactToGroupSheetState extends State<AddContactToGroupSheet> {
  final Set<int> _selectedUserIds = {};
  late final Set<int> _excludedMemberIds = _existingMemberIds();

  @override
  void initState() {
    super.initState();
    final bloc = getIt<ContactsBloc>();
    if (bloc.state is! ContactsLoaded) {
      bloc.add(ContactsLoad());
    } else {
      bloc.add(ContactsSearch(''));
    }
  }

  @override
  void dispose() {
    getIt<ContactsBloc>().add(ContactsSearch(''));
    super.dispose();
  }

  void _toggleSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _onDone() {
    if (_selectedUserIds.isEmpty) return;
    for (final userId in _selectedUserIds) {
      getIt<ChatDetailsBloc>().add(AddMembersToChat(userId));
    }
    context.pop();
  }

  Set<int> _existingMemberIds() {
    final members = getIt<ChatDetailsBloc>().state.chat?.memberInfo;
    if (members == null) return const {};
    return members.map((m) => m.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: Container(
        height: context.mediaSize.height * 0.92,
        decoration: BoxDecoration(
          color: context.appColors.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AddContactToGroupAppBar(
                isDoneEnabled: _selectedUserIds.isNotEmpty,
                onDone: _onDone,
              ),
              AddContactToGroupSearchField(
                selectedUserIds: _selectedUserIds,
                onRemove: _toggleSelection,
              ),
              Expanded(
                child: AddContactToGroupList(
                  selectedUserIds: _selectedUserIds,
                  excludedUserIds: _excludedMemberIds,
                  onTap: _toggleSelection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
