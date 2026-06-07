import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_button.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/feature/settings/view/widgets/change_photo_button.dart';
import 'package:lets_talk/feature/settings/view/widgets/edit_profile_header.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_avatar.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_delete_account_tile.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_name_group.dart';
import 'package:lets_talk/feature/settings/view/widgets/profile_phone_card.dart';

class EditProfileDetailsPage extends StatelessWidget {
  const EditProfileDetailsPage({super.key});

  void _onLogout(BuildContext context) {
    context.go(Routes.settings.path);
    context.read<AuthBloc>().add(AuthLogout());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.accountDeleted) {
          context.read<AuthBloc>().add(AuthLogout());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status != ProfileStatus.loaded &&
              state.status != ProfileStatus.saving &&
              state.status != ProfileStatus.avatarUploadLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              body: Column(
                children: [
                  const EditProfileHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        children: const [
                          Center(child: ProfileAvatar()),
                          SizedBox(height: 12),
                          ChangePhotoButton(),
                          SizedBox(height: 28),
                          ProfileNamesGroup(),
                          SizedBox(height: 12),
                          ProfilePhoneCard(),
                          SizedBox(height: 12),
                          ProfileDeleteAccountTile(),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: CButton.secondary(
                        label: context.s.logout,
                        icon: Icons.logout,
                        onPressed: () => _onLogout(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
