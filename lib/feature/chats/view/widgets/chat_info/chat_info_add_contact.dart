import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
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
    final isDark = context.theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;

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
          return Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                final phone = member?.phone;
                if (member == null || phone == null) return;
                ctx.read<AddContactBloc>().add(
                      AddContactSubmitted(
                        Contact(
                          phone: phone,
                          firstName: member?.firstName ?? phone,
                          lastName: member?.lastName ?? '',
                          fullName: member?.fullName ?? phone,
                          email: '',
                          address: '',
                          imageUrl: '',
                        ),
                      ),
                    );
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color:
                                const Color(0xFF9A9A9A).withValues(alpha: 0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 15,
                            spreadRadius: -3,
                          ),
                        ],
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text(
                    context.s.addToContacts,
                    style: AppTypography.textMdSemiBold
                        .copyWith(color: AppColors.brand),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
