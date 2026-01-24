import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class ChatDetailsSkeleton extends StatelessWidget {
  const ChatDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.only(
        top: context.padding.top + 60,
        bottom: 16,
      ),
      itemCount: 18,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              CSkeleton(
                width: 100 + (index % 3) * 50.0,
                height: 30,
                radius: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}
