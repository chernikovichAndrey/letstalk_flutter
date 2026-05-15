import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/constants/app_typography.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/c_avatar.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

class CallContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;

  const CallContactTile({
    super.key,
    required this.contact,
    required this.onAudioCall,
    required this.onVideoCall,
  });

  Widget _actionIcon(String asset, VoidCallback onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.brand, BlendMode.srcIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.messageLight : AppColors.messageDark;
    final subtitleColor = isDark ? AppColors.grayLight : AppColors.grayDark;
    final borderColor = isDark ? AppColors.messageDark : AppColors.messageLight;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CAvatar(
            imageUrl: contact.imageUrl != null && contact.imageUrl!.isNotEmpty
                ? contact.imageUrl
                : null,
            name: contact.fullName,
            radius: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.fullName,
                          style: AppTypography.textMdMedium.copyWith(
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (contact.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contact.phone,
                            style: AppTypography.textSmMedium.copyWith(
                              fontWeight: FontWeight.w400,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _actionIcon('assets/icons/phone.svg', onAudioCall),
                  const SizedBox(width: 12),
                  _actionIcon('assets/icons/videocamera.svg', onVideoCall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
