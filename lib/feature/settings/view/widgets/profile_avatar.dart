import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/settings/data/model/user_model.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});


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
        // Handle different state types
        if (state is! ProfileLoaded && state is! ProfileSaving && state is! AvatarUploadLoading) {
          return const SizedBox.shrink();
        }

        // Extract user based on state type
        final user = state is ProfileLoaded ? state.user :
                     state is ProfileSaving ? state.user :
                     state is AvatarUploadLoading ? state.user : null;
        
        if (user == null) {
          return const SizedBox.shrink();
        }

        return CAvatar(
          imageUrl: user.avatarUrl,
          name: _getUserDisplayName(user),
          radius: 60,
          isLoading: state is AvatarUploadLoading,
        );
      },
    );
  }
}