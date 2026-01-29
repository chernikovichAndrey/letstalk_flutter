import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_add_contact.dart';
import 'package:lets_talk/feature/chats/view/widgets/chat_info/chat_info_row.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ChatInfoUserInfo extends StatelessWidget {
  final MemberInfo? member;

  const ChatInfoUserInfo({super.key, this.member});

  @override
  Widget build(BuildContext context) {

    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          final hasInFriends = state is ContactsLoaded
              ? state.contacts.any((contact) => contact.registeredUserId == member?.id,)
              : false;
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.appColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (member?.phone != null && member!.phone!.isNotEmpty) ...[
                      ChatInfoRow(label: context.s.mobile, value: member?.phone!),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: context.appColors.divider,
                      ),
                    ],
                    ChatInfoRow(
                      label: context.s.username,
                      value:
                      member?.fullName ??
                          member?.firstName ??
                          member?.phone ??
                          '',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (!hasInFriends)
                ChatInfoAddContact(member: member),
            ],
          );
        },
      ),
    );
  }
}
