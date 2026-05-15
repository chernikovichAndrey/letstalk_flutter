import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_contact_tile.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';

class CallContactsSheet extends StatelessWidget {
  const CallContactsSheet({super.key});

  void _startCall(BuildContext context, Contact contact, {required bool isVideo}) {
    if (contact.registeredUserId == null) return;
    context.read<CallBloc>().add(
      CallInitiated(
        targetUserId: contact.registeredUserId!,
        fullName: contact.fullName,
        avatar: contact.imageUrl,
        isVideo: isVideo,
      ),
    );
    context.pop();
  }

  List<Contact> _registeredContacts(ContactsState state) {
    if (state is ContactsLoaded) {
      return state.contacts.where((c) => c.isRegistered).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocProvider.value(
      value: getIt<ContactsBloc>()..add(ContactsLoad()),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Scaffold(
          backgroundColor: appColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: appColors.backgroundColor,
            elevation: 0,
            leadingWidth: 56,
            leading: IconButton(
              onPressed: context.pop,
              icon: SvgPicture.asset(
                'assets/icons/arrow_left.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  appColors.glassForeground,
                  BlendMode.srcIn,
                ),
              ),
            ),
            actions: const [SizedBox(width: 56)],
            title: Text(
              context.s.newCall,
              style: AppTypography.textLgMedium.copyWith(
                color: appColors.glassForeground,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is ContactsLoading || state is ContactsActionInProgress) {
                return const ContactsSceleton();
              }
              final contacts = _registeredContacts(state);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CSearchBar(
                      hintText: context.s.search,
                      onChanged: (value) {
                        context.read<ContactsBloc>().add(ContactsSearch(value));
                      },
                    ),
                  ),
                  if (contacts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          context.s.noContacts,
                          style: AppTypography.textMdMedium.copyWith(
                            color: appColors.hintText,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return CallContactTile(
                          contact: contact,
                          onAudioCall: () =>
                              _startCall(context, contact, isVideo: false),
                          onVideoCall: () =>
                              _startCall(context, contact, isVideo: true),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
