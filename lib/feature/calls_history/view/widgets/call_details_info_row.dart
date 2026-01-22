import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class CallDetailsInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const CallDetailsInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.appColors.dateSeparatorText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
