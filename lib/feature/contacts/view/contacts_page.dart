import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/c_list_tile.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/common/widget/c_search_bar.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_app_bar.dart';
import 'package:lets_talk/feature/contacts/view/widgets/contacts_skeleton.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 66;

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
              return CRefreshableScrollView(
                edgeOffset: topPadding,
                onRefresh: () => _onRefresh(context),
                slivers: [
                  if (state is ContactsLoaded) ...[
                    SliverToBoxAdapter(
                      child: CSearchBar(
                        hintText: context.s.search,
                        onChanged: (value) {
                          context.read<ContactsBloc>().add(ContactsSearch(value));
                        },
                      ),
                    ),
                    if (state.contacts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.s.noContacts,
                            style: context.text.titleMedium?.copyWith(
                              color: context.color.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final contact = state.contacts[index];
                            final isSelected =
                                state.selectedContactIds.contains(contact.id);
                            return CListTile(
                              leading: CAvatar(
                                imageUrl:
                                    contact.imageUrl != null && contact.imageUrl!.isNotEmpty
                                        ? contact.imageUrl
                                        : null,
                                name: contact.fullName,
                              ),
                              title: contact.fullName,
                              subtitle: contact.phone.isNotEmpty ? contact.phone : null,
                              trailing: state.isSelectionMode
                                  ? Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? context.color.primary
                                          : context.color.onSurface.withValues(alpha: 0.3),
                                    )
                                  : null,
                              onTap: state.isSelectionMode
                                  ? () {
                                      if (contact.id != null) {
                                        context.read<ContactsBloc>().add(
                                              ContactsToggleContactSelection(contact.id!),
                                            );
                                      }
                                    }
                                  : null,
                            );
                          },
                          childCount: state.contacts.length,
                        ),
                      ),
                  ] else if (state is ContactsError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(state.message)),
                    )
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
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