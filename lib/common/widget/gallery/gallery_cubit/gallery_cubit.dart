import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'gallery_state.dart';

@injectable
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit() : super(GalleryInitial());

  int _page = 0;
  static const int _size = 80;
  AssetPathEntity? _currentPath;
  bool _isFetchingMore = false;

  Future<void> loadImages() async {
    if (state is GalleryLoading) return;
    emit(GalleryLoading());
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth || ps.hasAccess) {
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
        );
        if (paths.isNotEmpty) {
          _currentPath = paths[0];
          _page = 0;
          
          final List<AssetEntity> entities = await _currentPath!.getAssetListPaged(
            page: _page,
            size: _size,
          );
          
          emit(GalleryLoaded(
            entities,
            hasReachedMax: entities.length < _size,
          ));
        } else {
          emit(const GalleryLoaded([], hasReachedMax: true));
        }
      } else {
        emit(GalleryPermissionDenied());
      }
    } catch (e) {
      emit(GalleryError(e.toString()));
    }
  }

  Future<void> loadMoreImages() async {
    if (state is! GalleryLoaded) return;
    if (_isFetchingMore) return;
    
    final currentState = state as GalleryLoaded;
    if (currentState.hasReachedMax) return;
    if (_currentPath == null) return;

    _isFetchingMore = true;

    try {
      final nextPage = _page + 1;
      final List<AssetEntity> newEntities = await _currentPath!.getAssetListPaged(
        page: nextPage,
        size: _size,
      );

      _page = nextPage;
      _isFetchingMore = false;

      if (newEntities.isEmpty) {
        emit(GalleryLoaded(
          currentState.images,
          hasReachedMax: true,
        ));
      } else {
        emit(GalleryLoaded(
          currentState.images + newEntities,
          hasReachedMax: newEntities.length < _size,
        ));
      }
    } catch (e) {
      _isFetchingMore = false;
      // Keep previous state on error
    }
  }
}
