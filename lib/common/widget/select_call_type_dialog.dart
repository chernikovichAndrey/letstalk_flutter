import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';

class SelectCallTypeDialog {
  SelectCallTypeDialog(
    int id,
    String? fullName,
    String? avatar,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.s.selectCallType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.call),
              title: Text(context.s.audioCall),
              onTap: () {
                context.pop();
                context.read<CallBloc>().add(
                  CallInitiated(
                    targetUserId: id,
                    fullName: fullName,
                    avatar: avatar,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(context.s.videoCall),
              onTap: () {
                context.pop();
                context.read<CallBloc>().add(
                  CallInitiated(
                    targetUserId: id,
                    fullName: fullName,
                    avatar: avatar,
                    isVideo: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
