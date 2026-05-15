import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 12,
      itemBuilder: (context, index) => const _ChatListSkeletonItem(),
    );
  }
}

class _ChatListSkeletonItem extends StatelessWidget {
  const _ChatListSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        children: [
          const CSkeleton(width: 60, height: 60, radius: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6).copyWith(
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CSkeleton(width: 120, height: 16, radius: 4),
                      Spacer(),
                      CSkeleton(width: 36, height: 13, radius: 4),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Expanded(child: CSkeleton(height: 13, radius: 4)),
                      SizedBox(width: 8),
                      CSkeleton(width: 20, height: 20, radius: 10),
                    ],
                  ),
                  const SizedBox(height: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
