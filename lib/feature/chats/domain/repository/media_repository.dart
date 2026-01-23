import 'dart:io';
import 'package:lets_talk/feature/chats/data/model/media_model.dart';

abstract class MediaRepository {
  Future<Media> uploadMedia({
    required File file,
    required int chatId,
    required String fileType,
  });

  Future<void> downloadMedia(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  });
}
