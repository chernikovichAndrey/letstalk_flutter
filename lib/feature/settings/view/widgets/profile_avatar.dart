import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});


  String _getUserDisplayName(ProfileLoaded state) {
    final user = state.user;
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
        if (state is ProfileLoaded) {
          return CAvatar(
            imageUrl: state.user.avatarUrl,
            name: _getUserDisplayName(state),
            radius: 60,
            isLoading: state is AvatarUploadLoading,
          );
        }
        return CAvatar(
          radius: 60,
          isLoading: state is AvatarUploadLoading,
        );
      },
    );
  }
}