import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:photo_manager/photo_manager.dart';

class AttachmentBottomSheet extends StatefulWidget {
  const AttachmentBottomSheet({super.key});

  @override
  State<AttachmentBottomSheet> createState() => _AttachmentBottomSheetState();
}

class _AttachmentBottomSheetState extends State<AttachmentBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AssetEntity> _images = [];
  bool _isLoadingImages = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      Navigator.pop(context, File(photo.path));
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null && mounted) {
      Navigator.pop(context, File(result.files.single.path!));
    }
  }
  
  void _onImageTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null && mounted) {
      Navigator.pop(context, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: appColors.glassBackground, // Using glass background as base
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGalleryTab(),
                _buildFilesTab(),
              ],
            ),
          ),
          _buildBottomTabBar(context),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
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
            onTap: _openCamera,
            child: Container(
              color: Colors.grey[800],
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
            ),
          );
        }
        final asset = _images[index - 1];
        return GestureDetector(
          onTap: () => _onImageTap(asset),
          child: AssetThumbnail(asset: asset),
        );
      },
    );
  }

  Widget _buildFilesTab() {
    // Mock recent files for display purpose if no real history
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
               _buildOptionItem(
                 icon: Icons.image,
                 label: context.s.selectFromGallery,
                 color: Colors.purpleAccent,
                 onTap: () => _tabController.animateTo(0),
               ),
               const SizedBox(width: 16),
               _buildOptionItem(
                 icon: Icons.folder,
                 label: context.s.selectFromFiles,
                 color: Colors.blueAccent,
                 onTap: _pickFile,
               ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            context.s.recentFiles,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: 3, // Mock items
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
               return ListTile(
                 leading: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.blue.withOpacity(0.2),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: const Icon(Icons.description, color: Colors.blue),
                 ),
                 title: Text('app-release.apk.zip', style: TextStyle(color: Colors.white)),
                 subtitle: Text('39.4 MB • 21 Jan 2026', style: TextStyle(color: Colors.grey)),
               );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: Center(
        child: Container(
          width: 250, 
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), 
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.black, // Active tab bg
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: context.s.gallery),
              Tab(text: context.s.file),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  const AssetThumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.grey[900]);
      },
    );
  }
}
