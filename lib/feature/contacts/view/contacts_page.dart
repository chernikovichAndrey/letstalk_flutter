import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_app_bar.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_slivers.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.padding.top + 56;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is ContactsSyncingPhoneContacts) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        const SizedBox(height: 16),
                        Text('${(state.progress * 100).toInt()}%'),
                      ],
                    ),
                  ),
                );
              }
              if (state is ContactsLoading || state is ContactsActionInProgress) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const ContactsSceleton(),
                );
              }
              if (state is ContactsCreateChatInProgress) {
                return Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return CRefreshableScrollView(
                edgeOffset: topPadding,
                onRefresh: () => _onRefresh(context),
                slivers: [
                  ContactsSlivers(state: state),
                ],
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ContactsAppBar(),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final completer = Completer();
    context.read<ContactsBloc>().add(ContactsRefresh(completer: completer));
    return completer.future;
  }
}