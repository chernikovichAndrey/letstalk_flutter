import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:path_provider/path_provider.dart';

// Performance optimizations for 60fps:
// 1. ValueNotifier for all interactive params - no setState during gestures/sliders
// 2. ColorFiltered for adjustments - GPU-accelerated, instant response
// 3. Cached base image bytes - no re-encoding
// 4. RepaintBoundary - isolate expensive repaints
// 5. Image downscaling to max 1080px for preview
// 6. Heavy processing only on save, not during preview

class PhotoEditorPage extends StatefulWidget {
  final File imageFile;

  const PhotoEditorPage({super.key, required this.imageFile});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  img.Image? _image;
  img.Image? _originalImage;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Transform parameters
  int _rotation = 0; // 0, 90, 180, 270
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  
  // Crop parameters - using ValueNotifier for better performance
  final ValueNotifier<Offset> _imageOffsetNotifier = ValueNotifier(Offset.zero);
  final ValueNotifier<double> _scaleNotifier = ValueNotifier(1.0);
  double _baseScale = 1.0;
  
  // Adjustment parameters - using ValueNotifier for smooth sliders
  bool _isAdjusting = false;
  final ValueNotifier<double> _brightnessNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> _contrastNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> _saturationNotifier = ValueNotifier(1.0);
  
  // Cache for performance
  Uint8List? _cachedBaseImageBytes;
  
  @override
  void dispose() {
    _imageOffsetNotifier.dispose();
    _scaleNotifier.dispose();
    _brightnessNotifier.dispose();
    _contrastNotifier.dispose();
    _saturationNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    _originalImage = img.decodeImage(bytes);
    _image = img.copyResize(_originalImage!, 
      width: _originalImage!.width > 1080 ? 1080 : _originalImage!.width
    );
    // Pre-cache base image
    _cachedBaseImageBytes = Uint8List.fromList(img.encodeJpg(_image!, quality: 90));
    setState(() => _isLoading = false);
  }

  Future<File> _saveEditedImage() async {
    final scale = _scaleNotifier.value;
    final imageOffset = _imageOffsetNotifier.value;
    final brightness = _brightnessNotifier.value;
    final contrast = _contrastNotifier.value;
    final saturation = _saturationNotifier.value;
    
    var editedImage = img.copyResize(_image!, width: _image!.width);
    
    // Apply rotation
    if (_rotation == 90) editedImage = img.copyRotate(editedImage, angle: 90);
    if (_rotation == 180) editedImage = img.copyRotate(editedImage, angle: 180);
    if (_rotation == 270) editedImage = img.copyRotate(editedImage, angle: 270);
    
    // Apply flips
    if (_flipHorizontal) editedImage = img.flipHorizontal(editedImage);
    if (_flipVertical) editedImage = img.flipVertical(editedImage);
    
    // Apply adjustments
    if (brightness != 1.0) {
      editedImage = img.adjustColor(editedImage, brightness: (brightness - 1.0) * 128);
    }
    if (contrast != 1.0) {
      editedImage = img.adjustColor(editedImage, contrast: (contrast - 1.0) * 128);
    }
    if (saturation != 1.0) {
      editedImage = img.adjustColor(editedImage, saturation: (saturation - 1.0) * 128);
    }
    
    // Apply scale if needed
    if (scale != 1.0) {
      final newWidth = (editedImage.width * scale).round();
      final newHeight = (editedImage.height * scale).round();
      editedImage = img.copyResize(editedImage, width: newWidth, height: newHeight);
    }
    
    // Calculate the crop area based on offset
    final size = editedImage.width < editedImage.height 
        ? editedImage.width 
        : editedImage.height;
    
    // Calculate center considering offset (convert screen offset to image offset)
    final offsetX = (-imageOffset.dx * scale).round();
    final offsetY = (-imageOffset.dy * scale).round();
    
    final centerX = (editedImage.width ~/ 2) + offsetX;
    final centerY = (editedImage.height ~/ 2) + offsetY;
    final radius = size ~/ 2;
    
    final circularImage = img.Image(width: size, height: size);
    
    // Make background transparent
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final dx = x - radius;
        final dy = y - radius;
        if (dx * dx + dy * dy <= radius * radius) {
          final srcX = centerX - radius + x;
          final srcY = centerY - radius + y;
          if (srcX >= 0 && srcX < editedImage.width && 
              srcY >= 0 && srcY < editedImage.height) {
            circularImage.setPixel(x, y, editedImage.getPixel(srcX, srcY));
          }
        }
      }
    }
    
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(img.encodePng(circularImage));
    
    return file;
  }

  void _rotateRight() {
    setState(() {
      _rotation = (_rotation + 90) % 360;
      // Reset offset and scale after rotation for better UX
      _imageOffsetNotifier.value = Offset.zero;
      _scaleNotifier.value = 1.0;
      _baseScale = 1.0;
    });
  }

  void _toggleFlipHorizontal() {
    setState(() {
      _flipHorizontal = !_flipHorizontal;
    });
  }

  void _resetAdjustments() {
    _brightnessNotifier.value = 1.0;
    _contrastNotifier.value = 1.0;
    _saturationNotifier.value = 1.0;
  }

  void _resetCrop() {
    setState(() {
      _imageOffsetNotifier.value = Offset.zero;
      _scaleNotifier.value = 1.0;
      _baseScale = 1.0;
    });
  }

  // Create color matrix for adjustments
  ColorFilter _createColorFilter(double brightness, double contrast, double saturation) {
    // Convert to -1..1 range for better control
    final b = (brightness - 1.0) * 0.5;
    final c = contrast;
    final s = saturation;
    
    // Simplified color matrix for performance
    return ColorFilter.matrix([
      c * s, 0, 0, 0, b * 255,
      0, c * s, 0, 0, b * 255,
      0, 0, c * s, 0, b * 255,
      0, 0, 0, 1, 0,
    ]);
  }

  Widget _buildImagePreview() {
    if (_isLoading || _image == null || _cachedBaseImageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final rotationRadians = _rotation * 3.14159 / 180;

    return RepaintBoundary(
      child: Container(
        color: Colors.black,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth * 0.9
                  : constraints.maxHeight * 0.9;

              return SizedBox(
                width: size,
                height: size,
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseScale = _scaleNotifier.value;
                  },
                  onScaleUpdate: (details) {
                    // Update scale and position without setState for better performance
                    _scaleNotifier.value = (_baseScale * details.scale).clamp(0.5, 3.0);
                    _imageOffsetNotifier.value += details.focalPointDelta;
                  },
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // Full image in background - use ValueListenableBuilder for smooth transforms
                        Positioned.fill(
                          child: ValueListenableBuilder<Offset>(
                            valueListenable: _imageOffsetNotifier,
                            builder: (context, offset, child) {
                              return ValueListenableBuilder<double>(
                                valueListenable: _scaleNotifier,
                                builder: (context, scale, _) {
                                  return ValueListenableBuilder<double>(
                                    valueListenable: _brightnessNotifier,
                                    builder: (context, brightness, _) {
                                      return ValueListenableBuilder<double>(
                                        valueListenable: _contrastNotifier,
                                        builder: (context, contrast, _) {
                                          return ValueListenableBuilder<double>(
                                            valueListenable: _saturationNotifier,
                                            builder: (context, saturation, _) {
                                              return Transform(
                                                alignment: Alignment.center,
                                                transform: Matrix4.identity()
                                                  ..translate(offset.dx, offset.dy)
                                                  ..scale(scale)
                                                  ..rotateZ(rotationRadians)
                                                  ..scale(
                                                    _flipHorizontal ? -1.0 : 1.0,
                                                    _flipVertical ? -1.0 : 1.0,
                                                    1.0,
                                                  ),
                                                child: ColorFiltered(
                                                  colorFilter: _createColorFilter(brightness, contrast, saturation),
                                                  child: Image.memory(
                                                    _cachedBaseImageBytes!,
                                                    fit: BoxFit.cover,
                                                    gaplessPlayback: true,
                                                    cacheWidth: 1080,
                                                    filterQuality: FilterQuality.medium,
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
                              child: CustomPaint(
                                painter: CropOverlayPainter(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_isAdjusting) {
      return _buildAdjustmentControls();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(
              icon: Icons.close,
              label: 'Back',
              onTap: () => context.pop(),
            ),
            _buildIconButton(
              icon: Icons.crop_rotate,
              label: 'Rotate',
              onTap: _rotateRight,
            ),
            _buildIconButton(
              icon: Icons.change_history_outlined,
              label: 'Crop',
              onTap: _resetCrop,
            ),
            _buildIconButton(
              icon: Icons.flip,
              label: 'Flip',
              onTap: _toggleFlipHorizontal,
            ),
            _buildIconButton(
              icon: Icons.tune,
              label: 'Adjust',
              onTap: () {
                setState(() => _isAdjusting = !_isAdjusting);
              },
            ),
            _buildIconButton(
              icon: Icons.check,
              label: 'Done',
              onTap: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                try {
                  final editedFile = await _saveEditedImage();
                  
                  // Save to gallery
                  try {
                    await Gal.putImage(editedFile.path);
                  } catch (e) {
                    // Gallery save failed, but continue
                    print('Failed to save to gallery: $e');
                  }
                  
                  if (mounted) {
                    context.pop(editedFile);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save image: $e'),
                        backgroundColor: context.appColors.destructive,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentControls() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                  'Adjustments',
                  style: TextStyle(
                    color: context.appColors.glassForeground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _resetAdjustments,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: context.appColors.telegramBlue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.appColors.glassForeground),
                      onPressed: () {
                        setState(() => _isAdjusting = false);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: _brightnessNotifier,
              builder: (context, value, _) {
                return _buildSlider('Brightness', value, 0.0, 2.0, (newValue) {
                  _brightnessNotifier.value = newValue;
                });
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: _contrastNotifier,
              builder: (context, value, _) {
                return _buildSlider('Contrast', value, 0.0, 2.0, (newValue) {
                  _contrastNotifier.value = newValue;
                });
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: _saturationNotifier,
              builder: (context, value, _) {
                return _buildSlider('Saturation', value, 0.0, 2.0, (newValue) {
                  _saturationNotifier.value = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appColors.glassForeground.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: context.appColors.telegramBlue,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.appColors.secondaryBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isEnabled 
                  ? context.appColors.glassForeground
                  : context.appColors.glassForeground.withValues(alpha: 0.3),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isEnabled
                  ? context.appColors.glassForeground.withValues(alpha: 0.7)
                  : context.appColors.glassForeground.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appColors.glassForeground),
          onPressed: _isSaving ? null : () => context.pop(),
        ),
        title: Text(
          'Edit Photo',
          style: TextStyle(
            color: context.appColors.glassForeground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildImagePreview()),
              _buildBottomBar(),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Create path with hole in the middle
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    // Draw semi-transparent black overlay with circular cutout
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);
    
    canvas.drawPath(path, overlayPaint);

    // Draw white circle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
