import 'package:photo_manager/photo_manager.dart';

sealed class GalleryState {
  const GalleryState();
}

final class GalleryInitial extends GalleryState {}

final class GalleryLoading extends GalleryState {}

final class GalleryLoaded extends GalleryState {
  final List<AssetEntity> images;

  const GalleryLoaded(this.images);
}

final class GalleryPermissionDenied extends GalleryState {}

final class GalleryError extends GalleryState {
  final String message;

  const GalleryError(this.message);
}
