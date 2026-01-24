import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';
import 'package:lets_talk/feature/chats/domain/repository/media_repository.dart';

@LazySingleton(as: MediaRepository)
class MediaRepositoryImpl implements MediaRepository {
  final ApiService _apiService;

  MediaRepositoryImpl(this._apiService);

  @override
  Future<Media> uploadMedia({
    required File file,
    required int chatId,
    required String fileType,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'chat_id': chatId,
      'file_type': fileType,
    });

    final response = await _apiService.post(
      ApiConstants.mediaUpload,
      data: formData,
    );

    final mediaResponse = MediaUploadResponse.fromJson(response.data);
    return mediaResponse.media;
  }

  @override
  Future<void> downloadMedia(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _apiService.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
