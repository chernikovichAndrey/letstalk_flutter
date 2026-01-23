import 'package:photo_manager/photo_manager.dart';

sealed class GalleryState {
  const GalleryState();
}

final class GalleryInitial extends GalleryState {}

final class GalleryLoading extends GalleryState {}

final class GalleryLoaded extends GalleryState {
  final List<AssetEntity> images;
  final bool hasReachedMax;

  const GalleryLoaded(this.images, {this.hasReachedMax = false});
}

final class GalleryPermissionDenied extends GalleryState {}

final class GalleryError extends GalleryState {
  final String message;

  const GalleryError(this.message);
}
