import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/widget/glass_button.dart';

class CallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const CallActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButton(
          icon: icon,
          onTap: onTap,
          size: 60,
          iconColor: Colors.white,
          backgroundColor: backgroundColor,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
