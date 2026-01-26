import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/editor_bottom_button.dart';

class EditPhotoBottomBar extends StatelessWidget {
  final VoidCallback onRotate;
  final VoidCallback onResetCrop;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onAdjusting;
  final Future<void>Function()? onSave;

  const EditPhotoBottomBar({
    super.key,
    required this.onRotate,
    required this.onResetCrop,
    required this.onFlipHorizontal,
    required this.onAdjusting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            EditorBottomButton(
              icon: Icons.arrow_back_ios_new,
              label: context.s.photoEditorBack,
              onTap: () => context.pop(),
            ),
            EditorBottomButton(
              icon: Icons.crop_rotate,
              label: context.s.photoEditorRotate,
              onTap: onRotate,
            ),
            EditorBottomButton(
              icon: Icons.flip,
              label: context.s.photoEditorFlip,
              onTap: onFlipHorizontal,
            ),
            EditorBottomButton(
              icon: Icons.tune,
              label: context.s.photoEditorAdjust,
              onTap: onAdjusting,
            ),
            EditorBottomButton(
              icon: Icons.check,
              label: context.s.photoEditorDone,
              onTap: onSave,
            ),
          ],
        ),
      ),
    );
  }
}
