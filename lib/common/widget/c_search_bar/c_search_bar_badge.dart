import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_talk/common/constants/app_colors.dart';

class CSearchBarBadgeData {
  final String label;
  final ImageProvider? avatar;

  const CSearchBarBadgeData({
    required this.label,
    this.avatar,
  });
}

class CSearchBarBadge extends StatelessWidget {
  final CSearchBarBadgeData data;
  final VoidCallback? onRemoved;

  const CSearchBarBadge({
    super.key,
    required this.data,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.avatar != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: data.avatar!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            data.label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: AppColors.backgroundLight,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemoved,
            child: const Icon(
              Icons.cancel_outlined,
              size: 20,
              color: AppColors.backgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}
