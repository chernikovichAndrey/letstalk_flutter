import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_talk/feature/chats/domain/gallery_cubit/gallery_cubit.dart';
import 'package:lets_talk/feature/chats/domain/gallery_cubit/gallery_state.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/asset_thumbnail.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/galery_camera_preview.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GalleryCubit()..loadImages(),
      child: const _GalleryContent(),
    );
  }
}

class _GalleryContent extends StatefulWidget {
  const _GalleryContent();

  @override
  State<_GalleryContent> createState() => _GalleryContentState();
}

class _GalleryContentState extends State<_GalleryContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GalleryCubit>().loadMoreImages();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
    );
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryCubit, GalleryState>(
      builder: (context, state) {
        if (state is GalleryLoading || state is GalleryInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GalleryPermissionDenied) {
          return const Center(
            child: Text(
              'No permission to access gallery',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (state is GalleryError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final images =
            state is GalleryLoaded ? state.images : <AssetEntity>[];

        return CustomScrollView(
          controller: _scrollController,
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: openCamera,
                      child: Container(
                        color: Colors.grey[800],
                        child: GaleryCameraPreview(),
                      ),
                    );
                  }
                  if (images.isEmpty && index > 0) return const SizedBox();
                  final asset = images[index - 1];
                  return GestureDetector(
                    onTap: () => onImageTap(asset),
                    child: AssetThumbnail(asset: asset),
                  );
                }, childCount: (images.length + 1).clamp(0, 5)),
              ),
            ),
            if (images.length > 4)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final asset = images[index + 4];
                    return GestureDetector(
                      onTap: () => onImageTap(asset),
                      child: AssetThumbnail(asset: asset),
                    );
                  }, childCount: images.length - 4),
                ),
              ),
          ],
        );
      },
    );
  }
}
