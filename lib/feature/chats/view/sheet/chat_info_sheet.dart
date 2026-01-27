import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/extension/list_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/common/widget/glass_button.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

class ChatInfoSheet extends StatelessWidget {
  const ChatInfoSheet({super.key});

  MemberInfo? _getChatMember(ChatDetailsState state) {
    final myId = (getIt<ProfileBloc>().state as ProfileLoaded).user.id;
    return state.chat?.memberInfo?.firstWhereOrNull((member) => member.id != myId);
  }

  String? _getMemberAvatar(ChatDetailsState state) {
    final member = _getChatMember(state);
    if (member == null) return null;
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return '${Env.baseUrl}uploads/${member.avatar}';
    }
    return null;
  }

  String? _getMemberName(ChatDetailsState state, {bool phone = false}) {
    final member = _getChatMember(state);
    if (member == null) return null;
    if (member.fullName != null && member.fullName!.isNotEmpty) {
      return member.fullName;
    }
    if (member.firstName != null && member.firstName!.isNotEmpty) {
      return member.firstName;
    }
    if (phone && member.phone != null && member.phone!.isNotEmpty) {
      return member.phone;
    }
    return null;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.phone,
          label: 'звонок',
          onTap: () {},
        ),
        _buildActionButton(
          context: context,
          icon: Icons.videocam,
          label: 'видео',
          onTap: () {},
        ),
        _buildActionButton(
          context: context,
          icon: Icons.notifications,
          label: 'звук',
          onTap: () {},
        ),
        _buildActionButton(
          context: context,
          icon: Icons.more_horiz,
          label: 'ещё',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.blue : Colors.black;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: context.appColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaSize.height * 0.92,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocProvider.value(
        value: getIt<ChatDetailsBloc>(),
        child: BlocBuilder<ChatDetailsBloc, ChatDetailsState>(
          builder: (context, state) {
            //TODO: add group style

            //this is for 1x1
            // final member = state.chat?.memberInfo?.firstWhereOrNull((member) =>
            //   member.id != (getIt<ProfileBloc>().state as ProfileLoaded).user.id
            // );
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          CAvatar(
                            imageUrl: _getMemberAvatar(state),
                            name: _getMemberName(state),
                            radius: 60,
                            isLoading: state is AvatarUploadLoading,
                          ),
                          Text(
                            _getMemberName(state, phone: true) ?? '',
                            style: TextStyle(
                              color: context.appColors.glassForeground,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 28,),
                          _buildActionButtons(context),
                          SizedBox(height: 28,)
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassButton(icon: Icons.close, onTap: context.pop),
                          GlassButton(icon: Icons.edit, onTap: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
