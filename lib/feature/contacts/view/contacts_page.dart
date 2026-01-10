import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/c_list_tile.dart';
import 'package:lets_talk/common/widget/c_refreshable_scroll_view.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';
import 'package:lets_talk/feature/contacts/data/repository/contacts_repository_impl.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactsBloc(ContactsRepositoryImpl())..add(ContactsLoad()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.s.contacts),
          centerTitle: true,
        ),
        body: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            if (state is ContactsLoading) {
              return ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const CSkeleton(width: 48, height: 48, radius: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CSkeleton(width: 140, height: 16, radius: 4),
                              const SizedBox(height: 8),
                              const CSkeleton(width: 100, height: 14, radius: 4),
                              const SizedBox(height: 8),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return CRefreshableScrollView(
              onRefresh: () => _onRefresh(context),
              slivers: [
                if (state is ContactsError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(state.message)),
                  )
                else if (state is ContactsLoaded)
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
                          return CListTile(
                            leading: CAvatar(
                              imageUrl: contact.imageUrl.isNotEmpty ? contact.imageUrl : null,
                              name: contact.fullName,
                            ),
                            title: contact.fullName,
                            subtitle: contact.phone.isNotEmpty ? contact.phone : null,
                          );
                        },
                        childCount: state.contacts.length,
                      ),
                    )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final completer = Completer();
    context.read<ContactsBloc>().add(ContactsRefresh(completer: completer));
    return completer.future;
  }
}
