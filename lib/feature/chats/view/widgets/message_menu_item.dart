import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class MessageMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const MessageMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: context.text.bodyMedium?.copyWith(
                color: isDestructive ? Colors.red : null,
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : context.icon.color,
            ),
          ],
        ),
      ),
    );
  }
}
