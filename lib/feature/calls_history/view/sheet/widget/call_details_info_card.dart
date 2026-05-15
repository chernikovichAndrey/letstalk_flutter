import 'package:flutter/material.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/feature/calls_history/view/sheet/widget/call_details_info_row.dart';

class CallDetailsInfoCard extends StatelessWidget {
  final List<MapEntry<String, String>> entries;

  const CallDetailsInfoCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.messageDark : AppColors.white;
    final dividerColor = isDark
        ? AppColors.messageLight.withValues(alpha: 0.1)
        : AppColors.messageDark.withValues(alpha: 0.1);

    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isFirst = i == 0;
      final isLast = i == entries.length - 1;
      children.add(
        Padding(
          padding: EdgeInsets.only(
            top: isFirst ? 16 : 12,
            bottom: isLast ? 16 : 12,
          ),
          child: CallDetailsInfoRow(label: entry.key, value: entry.value),
        ),
      );
      if (!isLast) {
        children.add(Container(height: 1, color: dividerColor));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
