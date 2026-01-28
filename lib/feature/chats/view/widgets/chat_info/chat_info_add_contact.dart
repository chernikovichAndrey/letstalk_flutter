import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoAddContact extends StatelessWidget {
  const ChatInfoAddContact({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AddContactBloc>(),
      child: BlocListener<AddContactBloc, AddContactState>(
        listener: (context, state) {
          if (state is AddContactSuccess) {
            showSuccessToast(context.s.contactAdded);
            getIt<ContactsBloc>().add(ContactsLoad());
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  final myId = getIt<ProfileBloc>().state.user?.id;
                  final member = state.chat?.memberInfo?.firstWhereOrNull(
                    (member) => member.id != myId,
                  );
                  if (member != null && member.phone != null) {
                    context.read<AddContactBloc>().add(
                      AddContactSubmitted(
                        Contact(
                          phone: member.phone ?? '',
                          firstName: member.firstName ?? member.phone ?? '',
                          lastName: member.lastName ?? '',
                          fullName: member.fullName ?? member.phone ?? '',
                          email: '',
                          address: '',
                          imageUrl: '',
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.s.addToContacts,
                    style: context.text.bodyLarge?.copyWith(color: Colors.blue),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
