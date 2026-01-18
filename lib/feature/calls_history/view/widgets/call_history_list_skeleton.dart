import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class CallHistoryListSkeleton extends StatelessWidget {
  const CallHistoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 15,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return const _CallListSkeletonItem();
      },
    );
  }
}

class _CallListSkeletonItem extends StatelessWidget {
  const _CallListSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CSkeleton(
            width: 48,
            height: 48,
            radius: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CSkeleton(
                  width: 140,
                  height: 16,
                  radius: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CSkeleton(
                      width: 14,
                      height: 14,
                      radius: 2,
                    ),
                    const SizedBox(width: 4),
                    const CSkeleton(
                      width: 100,
                      height: 14,
                      radius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const CSkeleton(
                width: 40,
                height: 12,
                radius: 4,
              ),
              const SizedBox(width: 8),
              const CSkeleton(
                width: 20,
                height: 20,
                radius: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
