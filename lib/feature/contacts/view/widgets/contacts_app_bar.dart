import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactsAppBar extends StatelessWidget {
  const ContactsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final baseColor = appColors.glassForeground;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Stack(
          children: [
            const Positioned.fill(child: GlassAppBarBackground()),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BlocBuilder<ContactsBloc, ContactsState>(
                            builder: (context, state) {
                              if (state is ContactsLoaded &&
                                  state.allContacts.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              IconData icon = Icons.edit;
                              VoidCallback? onTap = () => context
                                  .read<ContactsBloc>()
                                  .add(ContactsToggleSelectionMode());

                              if (state is ContactsLoaded &&
                                  state.isSelectionMode) {
                                return Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      color: appColors.glassForeground,
                                      onPressed: () => context.read<ContactsBloc>().add(
                                        ContactsToggleSelectionMode(),
                                      ),
                                    ),
                                    if (state.selectedContactIds.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: appColors.glassForeground,
                                        onPressed: () => context
                                            .read<ContactsBloc>()
                                            .add(ContactsDeleteSelected()),
                                      ),
                                  ],
                                );
                              } else if (state is ContactsActionInProgress) {
                                onTap = null;
                              }
                              return IconButton(
                                icon: Icon(icon),
                                color: appColors.glassForeground,
                                onPressed: onTap,
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        context.s.contacts,
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: appColors.glassForeground,
                            onPressed: () async {
                              await context.push(Routes.createContact.path);
                              if (context.mounted) {
                                context.read<ContactsBloc>().add(ContactsRefresh());
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
