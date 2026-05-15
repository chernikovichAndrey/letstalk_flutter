import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class CallUserAvatar extends StatelessWidget {
  const CallUserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getIt<ProfileBloc>().state.user;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.orangeLight, AppColors.brand],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CAvatar(
                  imageUrl: user?.avatarUrl,
                  name: user?.fullName,
                  radius: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? context.s.defaultUserName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
