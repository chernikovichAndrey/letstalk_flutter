import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class ChatsAppBarNewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const ChatsAppBarNewChatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Center(
        child: Material(
          color: AppColors.brand,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 28,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
