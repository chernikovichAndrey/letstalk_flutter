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
  final String? videoUrl;
  final UploadedBy? uploadedBy;
  final String? status;

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
    this.videoUrl,
    required this.downloadUrl,
    this.uploadedBy,
    this.status,
  });

  Media copyWith({
    int? id,
    String? type,
    String? mimeType,
    String? filename,
    int? size,
    int? duration,
    int? width,
    int? height,
    String? thumbnailUrl,
    String? downloadUrl,
    String? videoUrl,
    UploadedBy? uploadedBy,
    String? status,
  }) {
    return Media(
      id: id ?? this.id,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      filename: filename ?? this.filename,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
    );
  }

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
      videoUrl: json['video_url'] as String? ?? '',
      uploadedBy: json['uploaded_by'] != null
          ? UploadedBy.fromJson(json['uploaded_by'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? '',
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
