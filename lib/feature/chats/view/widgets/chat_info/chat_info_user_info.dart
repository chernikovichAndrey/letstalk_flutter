import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
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
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final hasPhone =
        member?.phone != null && member!.phone!.isNotEmpty;

    return BlocProvider.value(
      value: getIt<ContactsBloc>(),
      child: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          final hasInFriends = state is ContactsLoaded
              ? state.contacts
                  .any((contact) => contact.registeredUserId == member?.id)
              : false;

          return Column(
            children: [
              if (hasPhone)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ChatInfoRow(
                    label: context.s.mobile,
                    value: member?.phone,
                  ),
                ),
              if (!hasInFriends && member != null) ...[
                const SizedBox(height: 16),
                ChatInfoAddContact(member: member),
              ],
            ],
          );
        },
      ),
    );
  }
}
