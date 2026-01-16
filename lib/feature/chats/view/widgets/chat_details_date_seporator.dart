import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class DateSeparator extends StatelessWidget {
  final String date;

  const DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: appColors.dateSeparatorBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: appColors.dateSeparatorText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
