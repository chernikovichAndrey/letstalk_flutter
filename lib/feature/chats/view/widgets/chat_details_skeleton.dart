import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class ChatDetailsSkeleton extends StatelessWidget {
  const ChatDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CSkeleton(width: 50, height: 50, radius: 25),
              CSkeleton(
                width: MediaQuery.of(context).size.width - 220,
                height: 50,
                radius: 25,
              ),
              CSkeleton(width: 50, height: 50, radius: 25),
            ],
          ),
        ),
        ListView.builder(
          reverse: true,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 160,
            bottom: 80,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final isMe = index % 2 == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  CSkeleton(
                    width: 100 + (index % 3) * 50.0,
                    height: 40,
                    radius: 12,
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom,
            top: MediaQuery.of(context).size.height - 120
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CSkeleton(width: 50, height: 50, radius: 50),
              CSkeleton(
                width: MediaQuery.of(context).size.width - 88,
                height: 50,
                radius: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
