import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class EditorBottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? background;

  const EditorBottomButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background ?? context.appColors.secondaryBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? context.appColors.glassForeground
                  : context.appColors.glassForeground.withValues(alpha: 0.3),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isEnabled
                  ? context.appColors.glassForeground.withValues(alpha: 0.7)
                  : context.appColors.glassForeground.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
