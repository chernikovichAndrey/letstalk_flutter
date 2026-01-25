import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
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
              if (state is ProfileLoading) {
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is ProfileLoaded) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: 28),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            ProfileWidget(user: state.user),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(AuthLogout());
                                },
                                child: Text(context.s.logout),
                              ),
                            ),
                            const SizedBox(height: 40),
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
