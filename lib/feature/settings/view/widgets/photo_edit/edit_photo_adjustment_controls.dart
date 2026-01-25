import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/edit_photo_slider.dart';

class EditPhotoAdjustmentControls extends StatelessWidget {
  final VoidCallback onResetAdjustments;
  final VoidCallback onBack;
  final ValueNotifier<double> brightnessNotifier;
  final ValueNotifier<double> contrastNotifier;
  final ValueNotifier<double> saturationNotifier;

  const EditPhotoAdjustmentControls({
    super.key,
    required this.onResetAdjustments,
    required this.onBack,
    required this.brightnessNotifier,
    required this.contrastNotifier,
    required this.saturationNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.s.photoEditorAdjustments,
                  style: TextStyle(
                    color: context.appColors.glassForeground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: onResetAdjustments,
                      child: Text(
                        context.s.photoEditorReset,
                        style: TextStyle(
                          color: context.appColors.telegramBlue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.appColors.glassForeground,
                      ),
                      onPressed: onBack,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: brightnessNotifier,
              builder: (context, value, _) {
                return EditPhotoSlider(
                  label: context.s.photoEditorBrightness,
                  value: value,
                  min: 0.0,
                  max: 2.0,
                  onChanged: (newValue) {
                    brightnessNotifier.value = newValue;
                  },
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: contrastNotifier,
              builder: (context, value, _) {
                return EditPhotoSlider(
                  label: context.s.photoEditorContrast,
                  value: value,
                  min: 0.0,
                  max: 2.0,
                  onChanged: (newValue) {
                    contrastNotifier.value = newValue;
                  },
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: saturationNotifier,
              builder: (context, value, _) {
                return EditPhotoSlider(
                  label: context.s.photoEditorSaturation,
                  value: value,
                  min: 0.0,
                  max: 2.0,
                  onChanged: (newValue) {
                    saturationNotifier.value = newValue;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
