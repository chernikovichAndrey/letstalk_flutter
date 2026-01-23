import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit() : super(GalleryInitial());

  Future<void> loadImages() async {
    emit(GalleryLoading());
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth || ps.hasAccess) {
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
        );
        if (paths.isNotEmpty) {
          // Fetch recently added images from the first album (usually "Recent")
          final List<AssetEntity> entities = await paths[0].getAssetListPaged(
            page: 0,
            size: 80,
          );
          emit(GalleryLoaded(entities));
        } else {
          emit(const GalleryLoaded([]));
        }
      } else {
        emit(GalleryPermissionDenied());
      }
    } catch (e) {
      emit(GalleryError(e.toString()));
    }
  }
}
