import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class CallHistoryNewCallButton extends StatelessWidget {
  const CallHistoryNewCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(
        child: GestureDetector(
          onTap: () => context.push(Routes.callContacts.path),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/plus.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
