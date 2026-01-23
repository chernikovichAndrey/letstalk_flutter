import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/asset_thumbnail.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchImages();
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

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: openCamera,
            child: Container(
              color: Colors.grey[800],
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
            ),
          );
        }
        final asset = _images[index - 1];
        return GestureDetector(
          onTap: () => onImageTap(asset),
          child: AssetThumbnail(asset: asset),
        );
      },
    );

  }
}