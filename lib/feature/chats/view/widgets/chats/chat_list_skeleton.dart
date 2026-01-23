import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 15,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        return const _ChatListSkeletonItem();
      },
    );
  }
}

class _ChatListSkeletonItem extends StatelessWidget {
  const _ChatListSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CSkeleton(
            width: 56,
            height: 56,
            radius: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CSkeleton(
                      width: 120,
                      height: 16,
                      radius: 4,
                    ),
                    const SizedBox(width: 8),
                    const CSkeleton(
                      width: 40,
                      height: 12,
                      radius: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: CSkeleton(
                        height: 14,
                        radius: 4,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const CSkeleton(
                      width: 20,
                      height: 20,
                      radius: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
