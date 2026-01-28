import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_action_button.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_widget.dart';
import 'package:lets_talk/feature/settings/view/widgets/settings_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.loading) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.status == ProfileStatus.loaded || 
                  state.status == ProfileStatus.avatarUploadLoading) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: 28),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              child: ProfileWidget(),
                            ),
                            SizedBox(height: 40,),
                            ProfileActionButton(
                              onTap: () => context.push(Routes.profileAvatarSheet),
                              label: context.s.changePhoto,
                              labelColor: context.appColors.telegramBlue,
                              icon: Icons.add_a_photo_outlined,
                              iconColor: context.appColors.telegramBlue,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const SettingsAppBar(),
          ),
        ],
      ),
    );
  }
}
