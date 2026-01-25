import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:lets_talk/app/router/arg/profile_edit_photo_args.dart';
import 'package:lets_talk/common/extension/build_context_router_ext.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/edit_photo_adjustment_controls.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/edit_photo_botton_bar.dart';
import 'package:lets_talk/feature/settings/view/widgets/photo_edit/edit_photo_image_preview.dart';
import 'package:path_provider/path_provider.dart';

class PhotoEditorPage extends StatefulWidget {

  const PhotoEditorPage({super.key});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  img.Image? _image;
  img.Image? _originalImage;
  bool _isLoading = true;
  bool _isSaving = false;
  
  int _rotation = 0; // 0, 90, 180, 270
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  
  final ValueNotifier<Offset> _imageOffsetNotifier = ValueNotifier(Offset.zero);
  final ValueNotifier<double> _scaleNotifier = ValueNotifier(1.0);
  double _baseScale = 1.0;
  
  bool _isAdjusting = false;
  final ValueNotifier<double> _brightnessNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> _contrastNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> _saturationNotifier = ValueNotifier(1.0);
  
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
    final imageFile = context.getArgsOrNull<ProfileEditPhotoArgs>()!.file;
    final bytes = await imageFile.readAsBytes();
    _originalImage = img.decodeImage(bytes);
    _image = img.copyResize(_originalImage!,
      width: _originalImage!.width,
      height: _originalImage!.height,
    );
    _cachedBaseImageBytes = Uint8List.fromList(img.encodeJpg(_image!, quality: 90));
    setState(() => _isLoading = false);
  }

  Future<File> _saveEditedImage() async {
    final scale = _scaleNotifier.value;
    final imageOffset = _imageOffsetNotifier.value;
    final brightness = _brightnessNotifier.value;
    final contrast = _contrastNotifier.value;
    final saturation = _saturationNotifier.value;
    
    var editedImage = img.copyResize(_originalImage!, width: _originalImage!.width);
    
    if (_rotation == 90) editedImage = img.copyRotate(editedImage, angle: 90);
    if (_rotation == 180) editedImage = img.copyRotate(editedImage, angle: 180);
    if (_rotation == 270) editedImage = img.copyRotate(editedImage, angle: 270);
    
    if (_flipHorizontal) editedImage = img.flipHorizontal(editedImage);
    if (_flipVertical) editedImage = img.flipVertical(editedImage);
    
    if (brightness != 1.0) {
      editedImage = img.adjustColor(editedImage, brightness: (brightness - 1.0) * 128);
    }
    if (contrast != 1.0) {
      editedImage = img.adjustColor(editedImage, contrast: (contrast - 1.0) * 128);
    }
    if (saturation != 1.0) {
      editedImage = img.adjustColor(editedImage, saturation: (saturation - 1.0) * 128);
    }
    
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final bottomBarHeight = 140.0; // approximate height of bottom bar
    final previewHeight = screenSize.height - appBarHeight - bottomBarHeight;
    final previewWidth = screenSize.width;
    
    final circleRadiusOnScreen = ((previewWidth < previewHeight ? previewWidth : previewHeight) / 2.0) * 0.8;
    
    final previewImageAspect = _image!.width / _image!.height;
    final screenAspect = previewWidth / previewHeight;
    final boxFitScale = screenAspect > previewImageAspect
        ? previewHeight / _image!.height  // fit by height (image is taller)
        : previewWidth / _image!.width;   // fit by width (image is wider)
    
    final scaleFactor = editedImage.width / _image!.width;
    
    final radius = (circleRadiusOnScreen / boxFitScale / scale * scaleFactor).round();
    
    final offsetInOriginalX = (imageOffset.dx / boxFitScale / scale) * scaleFactor;
    final offsetInOriginalY = (imageOffset.dy / boxFitScale / scale) * scaleFactor;
    
    final centerX = (editedImage.width / 2.0 - offsetInOriginalX).round();
    final centerY = (editedImage.height / 2.0 - offsetInOriginalY).round();
    
    final diameter = radius * 2;
    final circularImage = img.Image(width: diameter, height: diameter);
    
    for (var y = 0; y < diameter; y++) {
      for (var x = 0; x < diameter; x++) {
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

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    try {
      final editedFile = await _saveEditedImage();

      if (mounted) {
        context.pop(editedFile);
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(context.s.photoEditorSaveError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImageNotReady = _isLoading || _image == null || _cachedBaseImageBytes == null;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: isImageNotReady
                    ? const Center(child: CircularProgressIndicator())
                    : EditPhotoImagePreview(
                  rotationRadians: _rotation * 3.14159 / 180,
                  baseScale: _baseScale,
                  cachedBaseImageBytes: _cachedBaseImageBytes,
                  scaleNotifier: _scaleNotifier,
                  imageOffsetNotifier: _imageOffsetNotifier,
                  brightnessNotifier: _brightnessNotifier,
                  contrastNotifier: _contrastNotifier,
                  saturationNotifier: _saturationNotifier,
                  flipHorizontal: _flipHorizontal,
                  flipVertical: _flipVertical,
                  onScaleStart: (details) {
                    _baseScale = _scaleNotifier.value;
                  },
                  onScaleUpdate: (details) {
                    _scaleNotifier.value = (_baseScale * details.scale).clamp(0.5, 3.0);
                    _imageOffsetNotifier.value += details.focalPointDelta;
                  },
                ),
              ),
              if (!_isAdjusting)
                EditPhotoBottomBar(
                  onRotate: _rotateRight,
                  onResetCrop: _resetCrop,
                  onFlipHorizontal: _toggleFlipHorizontal,
                  onAdjusting: () {
                    setState(() => _isAdjusting = !_isAdjusting);
                  },
                  onSave: _isSaving ? null : _onSave,
                )
              else
                EditPhotoAdjustmentControls(
                  onResetAdjustments: _resetAdjustments,
                  onBack: () => setState(() { _isAdjusting = false; }),
                  brightnessNotifier: _brightnessNotifier,
                  contrastNotifier: _contrastNotifier,
                  saturationNotifier: _saturationNotifier,
                ),
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