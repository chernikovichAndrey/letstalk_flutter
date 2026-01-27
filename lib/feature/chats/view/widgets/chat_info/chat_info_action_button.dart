import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoActionButton extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ChatInfoActionButton({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: context.appColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            SizedBox(height: 4),
            Text(
              label,
              style: context.text.bodyLarge?.copyWith(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
