import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileBirthdayPicker extends StatelessWidget {
  const ProfileBirthdayPicker({super.key});


  String _formatBirthday(DateTime date) {
    return DateFormat('d MMMM yyyy', 'ru').format(date);
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        // Handle different state types
        if (state is! ProfileLoaded && state is! ProfileSaving && state is! AvatarUploadLoading) {
          return const SizedBox.shrink();
        }

        // Extract user and profile data based on state type
        final user = state is ProfileLoaded ? state.user :
                     state is ProfileSaving ? state.user :
                     state is AvatarUploadLoading ? state.user : null;
        
        if (user == null) {
          return const SizedBox.shrink();
        }

        final profileState = state is ProfileLoaded ? state : null;
        final editingBirthday = profileState?.editingBirthday;
        final selectedBirthday = editingBirthday ?? (user.birthday != null ? DateTime.tryParse(user.birthday!) : null);
        final isBirthdayPickerExpanded = profileState?.isBirthdayPickerExpanded ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.secondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        context.read<ProfileBloc>().add(
                          ProfileToggleBirthdayPickerEvent(),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.s.birthday,
                              style: context.text.bodyLarge,
                            ),
                            Text(
                              selectedBirthday != null
                                  ? _formatBirthday(selectedBirthday)
                                  : context.s.setBirthday,
                              style: TextStyle(
                                color: selectedBirthday != null
                                    ? context.appColors.glassForeground
                                    : context.appColors.hintText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isBirthdayPickerExpanded) ...[
                    Divider(
                      height: 1,
                      color: context.appColors.divider,
                      indent: 16,
                      endIndent: 16,
                    ),
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: selectedBirthday ?? DateTime(2000),
                        minimumYear: 1900,
                        maximumYear: DateTime.now().year,
                        onDateTimeChanged: (date) {
                          context.read<ProfileBloc>().add(
                            ProfileUpdateBirthdayEvent(date),
                          );
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: context.appColors.divider,
                      indent: 16,
                      endIndent: 16,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          context.read<ProfileBloc>().add(
                            ProfileUpdateBirthdayEvent(null),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                context.s.deleteBirthday,
                                style: TextStyle(
                                  color: context.appColors.telegramBlue,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}