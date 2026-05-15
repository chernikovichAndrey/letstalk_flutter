import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/contacts/domain/contacts_bloc/contacts_bloc.dart';

class SelectContactsForGroupAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onPressNext;

  const SelectContactsForGroupAppBar({
    super.key,
    required this.onPressNext,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.messageDark;

    return AppBar(
      backgroundColor: appColors.backgroundColor,
      surfaceTintColor: appColors.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: context.pop,
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: titleColor,
        ),
      ),
      centerTitle: true,
      title: Text(
        context.s.newGroup,
        style: AppTypography.textLgMedium.copyWith(color: titleColor),
      ),
      actions: [
        BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            final isEnabled = state is ContactsLoaded &&
                state.selectedContactIds.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isEnabled ? onPressNext : null,
                child: Center(
                  child: Text(
                    context.s.next,
                    style: AppTypography.textMdMedium.copyWith(
                      color: isEnabled
                          ? AppColors.brand
                          : AppColors.brand.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
