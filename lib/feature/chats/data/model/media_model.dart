class UploadedBy {
  final int userId;
  final String? phone;
  final String? name;

  UploadedBy({
    required this.userId,
    this.phone,
    this.name,
  });

  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
    );
  }
}

class Media {
  final int id;
  final String type;
  final String mimeType;
  final String filename;
  final int size;
  final int? duration;
  final int? width;
  final int? height;
  final String? thumbnailUrl;
  final String downloadUrl;
  final UploadedBy? uploadedBy;

  Media({
    required this.id,
    required this.type,
    required this.mimeType,
    required this.filename,
    required this.size,
    this.duration,
    this.width,
    this.height,
    this.thumbnailUrl,
    required this.downloadUrl,
    this.uploadedBy,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] as String? ?? json['file_type'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      size: int.tryParse(json['size'].toString()) ?? 0,
      duration: int.tryParse(json['duration'].toString()),
      width: int.tryParse(json['width'].toString()),
      height: int.tryParse(json['height'].toString()),
      thumbnailUrl: json['thumbnail_url'] as String?,
      downloadUrl: json['download_url'] as String? ?? '',
      uploadedBy: json['uploaded_by'] != null
          ? UploadedBy.fromJson(json['uploaded_by'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MediaUploadResponse {
  final String status;
  final Media media;

  MediaUploadResponse({
    required this.status,
    required this.media,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      status: json['status'] as String? ?? '',
      media: Media.fromJson(json['media'] as Map<String, dynamic>),
    );
  }
}
