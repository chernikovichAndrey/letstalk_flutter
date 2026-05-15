import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/contacts/domain/add_contact_bloc/add_contact_bloc.dart';
import 'package:lets_talk/feature/contacts/view/widgets/create_contact_save_button.dart';

class CreateContactAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CreateContactAppBar({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.messageLight : AppColors.messageDark;

    return AppBar(
      backgroundColor: context.appColors.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                context.s.createContactTitle,
                style: AppTypography.textLgMedium.copyWith(color: titleColor),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: context.pop,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: titleColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                BlocBuilder<AddContactBloc, AddContactState>(
                  builder: (context, state) {
                    return CreateContactSaveButton(
                      onTap: onSave,
                      isLoading: state is AddContactInProgress,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
