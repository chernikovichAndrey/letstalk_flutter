import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ChatInfoAddContact extends StatelessWidget {
  final MemberInfo? member;

  const ChatInfoAddContact({super.key, this.member});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AddContactBloc>(),
      child: BlocConsumer<AddContactBloc, AddContactState>(
        listener: (context, state) {
          if (state is AddContactSuccess) {
            showSuccessToast(context.s.contactAdded);
            getIt<ContactsBloc>().add(ContactsLoad());
          }
        },
        builder: (ctx, state) {
          return Container(
            decoration: BoxDecoration(
              color: context.appColors.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: () {
                if (member != null && member?.phone != null) {
                  ctx.read<AddContactBloc>().add(
                    AddContactSubmitted(
                      Contact(
                        phone: member?.phone ?? '',
                        firstName: member?.firstName ?? member?.phone ?? '',
                        lastName: member?.lastName ?? '',
                        fullName: member?.fullName ?? member?.phone ?? '',
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
            ),
          );
        },
      ),
    );
  }
}
