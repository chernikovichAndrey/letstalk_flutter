import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_app_bar.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_avatar.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_birthday_picker.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_name_group.dart';

class EditProfileDetailsPage extends StatelessWidget {
  const EditProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final topPadding = context.padding.top;
    final cardColor = appColors.secondaryBackground;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded &&
            state is! ProfileSaving &&
            state is! AvatarUploadLoading) {
          return Scaffold(
            backgroundColor: context.appColors.surfaceSecondary,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: context.appColors.surfaceSecondary,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: topPadding + 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ProfileAvatar(),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => GoRouter.of(
                                context,
                              ).push(Routes.profileAvatarSheet.path),
                              child: Text(
                                context.s.selectPhoto,
                                style: TextStyle(
                                  color: appColors.telegramBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ProfileNamesGroup(),
                            const SizedBox(height: 24),
                            ProfileBirthdayPicker(),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<AuthBloc>().add(AuthLogout());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cardColor,
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    context.s.logout,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ProfileAppBar(),
              ],
            ),
          ),
        );
      },
    );
  }
}
