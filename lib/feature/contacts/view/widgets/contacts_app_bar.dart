import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_app_bar_background.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';
import 'package:lets_talk/feature/contacts/view/create_contact_page_scope.dart';

class ContactsAppBar extends StatelessWidget {
  const ContactsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

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
                  vertical: 8.0,
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
                              IconData icon = Icons.edit;
                              VoidCallback? onTap = () => context
                                  .read<ContactsBloc>()
                                  .add(ContactsToggleSelectionMode());

                              if (state is ContactsLoaded &&
                                  state.isSelectionMode) {
                                return Row(
                                  children: [
                                    GlassButton(
                                      icon: Icons.close,
                                      onTap: () => context.read<ContactsBloc>().add(
                                        ContactsToggleSelectionMode(),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    if (state.selectedContactIds.isNotEmpty)
                                      GlassButton(
                                        icon: Icons.delete,
                                        onTap: () => context
                                            .read<ContactsBloc>()
                                            .add(ContactsDeleteSelected()),
                                      ),
                                  ],
                                );
                              } else if (state is ContactsActionInProgress) {
                                onTap = null;
                              }
                              return GlassButton(icon: icon, onTap: onTap ?? () {});
                            },
                          )
                        ],
                      ),
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 50,
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                context.s.contacts,
                                style: TextStyle(
                                  color: baseColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassButton(
                            icon: Icons.add,
                            onTap: () async {
                              final contactsBloc = context.read<ContactsBloc>();
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                const CreateContactPageScope(),
                              );

                              if (result == true) {
                                contactsBloc.add(ContactsLoad());
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
