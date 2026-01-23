import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class GaleryCameraPreview extends StatefulWidget {
  const GaleryCameraPreview({super.key});

  @override
  State<GaleryCameraPreview> createState() => _GaleryCameraPreviewState();
}

class _GaleryCameraPreviewState extends State<GaleryCameraPreview> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController?.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_cameraController != null && _cameraController!.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize?.height ?? 1,
              height: _cameraController!.value.previewSize?.width ?? 1,
              child: CameraPreview(_cameraController!),
            ),
          ),
        const Center(
          child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
        ),
      ],
    );
  }
}
