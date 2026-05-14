import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class ContactsAppBar extends StatelessWidget {
  const ContactsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.messageLight : AppColors.messageDark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
        child: Container(
          color: isDark 
              ? const Color(0xFF191919).withValues(alpha: 0.7) 
              : const Color(0xFFFFFFFF).withValues(alpha: 0.7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
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
                            if (state is ContactsLoaded &&
                                state.allContacts.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            Widget icon = SvgPicture.asset(
                              'assets/icons/pen.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(baseColor, BlendMode.srcIn),
                            );
                            VoidCallback? onTap = () => context
                                .read<ContactsBloc>()
                                .add(ContactsToggleSelectionMode());

                            if (state is ContactsLoaded &&
                                state.isSelectionMode) {
                              return Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    color: baseColor,
                                    onPressed: () => context.read<ContactsBloc>().add(
                                      ContactsToggleSelectionMode(),
                                    ),
                                  ),
                                  if (state.selectedContactIds.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: baseColor,
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
                              icon: icon,
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
                      style: AppTypography.headingXsMedium.copyWith(
                        color: baseColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await context.push(Routes.createContact.path);
                            if (context.mounted) {
                              context.read<ContactsBloc>().add(ContactsRefresh());
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.brand,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/icons/plus.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
