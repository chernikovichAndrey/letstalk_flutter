import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    required this.color,
    this.onTap,
    super.key,
  });

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ??
              () {
                if (context.canPop()) {
                  context.pop();
                }
              },
          child: Icon(Icons.arrow_back_ios_new, color: color, size: 22),
        ),
      ),
    );
  }
}
