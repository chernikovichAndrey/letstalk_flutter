import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_skeleton.dart';

class CallHistoryListSkeleton extends StatelessWidget {
  const CallHistoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
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
    final isDark = context.theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.messageDark : AppColors.messageLight;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          const CSkeleton(width: 40, height: 40, radius: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CSkeleton(width: 120, height: 16, radius: 4),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            CSkeleton(width: 16, height: 16, radius: 4),
                            SizedBox(width: 4),
                            CSkeleton(width: 110, height: 13, radius: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CSkeleton(width: 32, height: 12, radius: 4),
                  const SizedBox(width: 8),
                  const CSkeleton(width: 20, height: 20, radius: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
