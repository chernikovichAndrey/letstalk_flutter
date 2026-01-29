import 'package:flutter/cupertino.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

class ChatInfoDeleteMemberButton extends StatelessWidget {
  final VoidCallback onDelete;
  final double deleteButtonWidth;

  const ChatInfoDeleteMemberButton({
    super.key,
    required this.onDelete,
    required this.deleteButtonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: deleteButtonWidth,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemRed,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  context.s.deleteMember,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
