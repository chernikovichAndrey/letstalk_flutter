import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.radius = 50});

  final double radius;

  String _getUserDisplayName(UserModel user) {
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      return user.fullName!;
    }
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      if (user.lastName != null && user.lastName!.isNotEmpty) {
        return '${user.firstName} ${user.lastName}';
      }
      return user.firstName!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.status != ProfileStatus.loaded &&
            state.status != ProfileStatus.saving &&
            state.status != ProfileStatus.avatarUploadLoading) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return CAvatar(
          imageUrl: user.avatarUrl,
          name: _getUserDisplayName(user),
          radius: radius,
          isLoading: state.status == ProfileStatus.avatarUploadLoading,
        );
      },
    );
  }
}
