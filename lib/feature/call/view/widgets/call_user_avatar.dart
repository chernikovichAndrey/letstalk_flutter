import 'package:flutter/material.dart';
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
        color: Colors.black,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: context.appGradients.backgroundGradient,
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
