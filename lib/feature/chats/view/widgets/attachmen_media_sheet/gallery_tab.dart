import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/asset_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final List<AssetEntity> _images = [];
  bool _isLoadingImages = true;
  bool _hasPermission = false;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _fetchImages();
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

  Future<void> _fetchImages() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      _hasPermission = true;
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (paths.isNotEmpty) {
        final List<AssetEntity> entities = await paths[0].getAssetListPaged(
          page: 0,
          size: 80,
        );
        if (mounted) {
          setState(() {
            _images.addAll(entities);
            _isLoadingImages = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingImages = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
          _hasPermission = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Text(
          'No permission to access gallery',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    Future<void> openCamera() async {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        Navigator.pop(context, File(photo.path));
      }
    }

    void onImageTap(AssetEntity asset) async {
      final file = await asset.file;
      if (file != null && mounted) {
        Navigator.pop(context, file);
      }
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid(
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              repeatPattern: QuiltedGridRepeatPattern.same,
              pattern: [
                const QuiltedGridTile(2, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
              ],
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: openCamera,
                    child: Container(
                      color: Colors.grey[800],
                      child: Stack(
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
                      ),
                    ),
                  );
                }
                final asset = _images[index - 1];
                return GestureDetector(
                  onTap: () => onImageTap(asset),
                  child: AssetThumbnail(asset: asset),
                );
              },
              childCount: (_images.length + 1).clamp(0, 5),
            ),
          ),
        ),
        if (_images.length > 4)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final asset = _images[index + 4];
                  return GestureDetector(
                    onTap: () => onImageTap(asset),
                    child: AssetThumbnail(asset: asset),
                  );
                },
                childCount: _images.length - 4,
              ),
            ),
          ),
      ],
    );
  }
}
