import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/gallery/gallery_cubit/gallery_cubit.dart';
import 'package:lets_talk/common/widget/gallery/gallery_cubit/gallery_state.dart';
import 'package:lets_talk/common/widget/gallery/widget/gallery_permission_view.dart';
import 'package:lets_talk/common/widget/toasts.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/asset_thumbnail.dart';
import 'package:lets_talk/feature/chats/view/widgets/attachmen_media_sheet/galery_camera_preview.dart';
import 'package:photo_manager/photo_manager.dart';

const _fileSizeLimits = {
  AssetType.image: 20 * 1024 * 1024,
  AssetType.video: 500 * 1024 * 1024,
  AssetType.audio: 50 * 1024 * 1024,
};

class PhoneGallery extends StatelessWidget {
  final Function(File file) onGetMediaFile;

  const PhoneGallery({super.key, required this.onGetMediaFile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GalleryCubit>()..loadImages(),
      child: _GalleryContent(onGetMediaFile: onGetMediaFile),
    );
  }
}

class _GalleryContent extends StatefulWidget {
  final Function(File file) onGetMediaFile;
  const _GalleryContent({required this.onGetMediaFile});

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

  bool _checkFileSizeLimit(File file, AssetType type) {
    final sizeInBytes = file.lengthSync();
    final limit = _fileSizeLimits[type] ?? (50 * 1024 * 1024);
    return sizeInBytes <= limit;
  }

  Future<void> openCamera() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null && mounted) {
        widget.onGetMediaFile(File(photo.path));
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied' ||
          e.code == 'camera_access_restricted') {
        showErrorToast(context.s.cameraPermissionDescription);
      } else {
        showErrorToast(e.message ?? context.s.cameraPermissionDenied);
      }
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context.s.cameraPermissionDenied);
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
          return GalleryPermissionView(
            icon: Icons.photo_library_outlined,
            title: context.s.galleryPermissionDenied,
            description: context.s.galleryPermissionDescription,
          );
        }

        if (state is GalleryError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final images = state is GalleryLoaded ? state.images : <AssetEntity>[];

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
                  return AssetThumbnail(
                    asset: asset,
                    onTapAsset: (asset) async {
                      final file = await asset.file;
                      if (file == null || !context.mounted) return;
                      if (_checkFileSizeLimit(file, asset.type)) {
                        widget.onGetMediaFile(file);
                      } else {
                        final limit =
                            _fileSizeLimits[asset.type] ?? (50 * 1024 * 1024);
                        showErrorToast(
                          context.s.fileSizeLimitExceeded(
                            limit ~/ (1024 * 1024),
                          ),
                        );
                      }
                    },
                  );
                }, childCount: (images.length + 1).clamp(0, 5)),
              ),
            ),
            if (images.length > 4)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final asset = images[index + 4];
                    return AssetThumbnail(
                      asset: asset,
                      onTapAsset: (asset) async {
                        final file = await asset.file;
                        if (file == null || !context.mounted) return;
                        if (_checkFileSizeLimit(file, asset.type)) {
                          widget.onGetMediaFile(file);
                        } else {
                          final limit =
                              _fileSizeLimits[asset.type] ?? (50 * 1024 * 1024);
                          showErrorToast(
                            context.s.fileSizeLimitExceeded(
                              limit ~/ (1024 * 1024),
                            ),
                          );
                        }
                      },
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
