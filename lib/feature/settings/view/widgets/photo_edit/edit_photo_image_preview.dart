import 'package:flutter/material.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/crop_overlay_painter.dart';
import 'dart:typed_data';

class EditPhotoImagePreview extends StatelessWidget {
  final double rotationRadians;
  final double baseScale;
  final Uint8List? cachedBaseImageBytes;
  final ValueNotifier<double> scaleNotifier;
  final ValueNotifier<Offset> imageOffsetNotifier;
  final ValueNotifier<double> brightnessNotifier;
  final ValueNotifier<double> contrastNotifier;
  final ValueNotifier<double> saturationNotifier;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final bool flipHorizontal;

  const EditPhotoImagePreview({
    super.key,
    required this.rotationRadians,
    required this.baseScale,
    this.cachedBaseImageBytes,
    required this.scaleNotifier,
    required this.imageOffsetNotifier,
    required this.brightnessNotifier,
    required this.contrastNotifier,
    required this.saturationNotifier,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.flipHorizontal,
  });

  ColorFilter _createColorFilter(
    double brightness,
    double contrast,
    double saturation,
  ) {
    final b = (brightness - 1.0) * 0.5;
    final c = contrast;
    final s = saturation;

    return ColorFilter.matrix([
      c * s,
      0,
      0,
      0,
      b * 255,
      0,
      c * s,
      0,
      0,
      b * 255,
      0,
      0,
      c * s,
      0,
      b * 255,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: Colors.black,
        child: Center(
          child: GestureDetector(
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<Offset>(
                      valueListenable: imageOffsetNotifier,
                      builder: (context, offset, child) {
                        return ValueListenableBuilder<double>(
                          valueListenable: scaleNotifier,
                          builder: (context, scale, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: brightnessNotifier,
                              builder: (context, brightness, _) {
                                return ValueListenableBuilder<double>(
                                  valueListenable: contrastNotifier,
                                  builder: (context, contrast, _) {
                                    return ValueListenableBuilder<double>(
                                      valueListenable: saturationNotifier,
                                      builder: (context, saturation, _) {
                                        return Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()
                                            ..translateByDouble(
                                              offset.dx,
                                              offset.dy,
                                              0,
                                              1,
                                            )
                                            ..scaleByDouble(scale, scale, 1, 1)
                                            ..rotateZ(rotationRadians)
                                            ..scaleByDouble(
                                              flipHorizontal ? -1.0 : 1.0,
                                              1.0,
                                              1.0,
                                              1.0,
                                            ),
                                          child: ColorFiltered(
                                            colorFilter: _createColorFilter(
                                              brightness,
                                              contrast,
                                              saturation,
                                            ),
                                            child: Image.memory(
                                              cachedBaseImageBytes!,
                                              fit: BoxFit.scaleDown,
                                              gaplessPlayback: true,
                                              filterQuality:
                                                  FilterQuality.medium,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Semi-transparent overlay with circular cutout
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: CropOverlayPainter()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
