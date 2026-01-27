import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const ChatInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: context.appColors.hintText,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 4),
            Text(
              value ?? '',
              style: context.text.bodyLarge,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}