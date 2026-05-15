import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lets_talk/common/constants/app_colors.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/chats/view/widgets/chats/remove_chat_bottom_sheet.dart';

class ChatsAppBarLeading extends StatelessWidget {
  const ChatsAppBarLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.white : AppColors.messageDark;

    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        if (state is ChatsLoaded && state.isSelectionMode) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                onTap: () => context
                    .read<ChatsBloc>()
                    .add(ChatsToggleSelectionMode()),
                child: Icon(Icons.close, size: 24, color: iconColor),
              ),
              if (state.selectedChatIds.isNotEmpty)
                _IconBtn(
                  onTap: () => RemoveChatBottomSheet(context),
                  child: Icon(
                    Icons.delete_outline,
                    size: 24,
                    color: iconColor,
                  ),
                ),
            ],
          );
        }

        final hasChats = state is ChatsLoaded && state.chats.isNotEmpty;

        return _IconBtn(
          onTap: hasChats
              ? () =>
                  context.read<ChatsBloc>().add(ChatsToggleSelectionMode())
              : null,
          child: SvgPicture.asset(
            'assets/icons/pen.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              hasChats ? iconColor : iconColor.withValues(alpha: 0.4),
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _IconBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: child,
      ),
    );
  }
}
