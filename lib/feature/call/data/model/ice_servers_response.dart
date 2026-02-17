class IceServer {
  final String urls;
  final String? username;
  final String? credential;

  IceServer({
    required this.urls,
    this.username,
    this.credential,
  });

  factory IceServer.fromJson(Map<String, dynamic> json) {
    return IceServer(
      urls: json['urls'] as String? ?? '',
      username: json['username'] as String?,
      credential: json['credential'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urls': urls,
      if (username != null) 'username': username,
      if (credential != null) 'credential': credential,
    };
  }
}

class IceServersResponse {
  final bool success;
  final List<IceServer> iceServers;
  final int ttl;
  final String expiresAt;

  IceServersResponse({
    required this.success,
    required this.iceServers,
    required this.ttl,
    required this.expiresAt,
  });

  factory IceServersResponse.fromJson(Map<String, dynamic> json) {
    return IceServersResponse(
      success: json['success'] as bool? ?? false,
      iceServers: (json['iceServers'] as List<dynamic>?)
              ?.map((e) => IceServer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ttl: int.tryParse(json['ttl'].toString()) ?? 0,
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'iceServers': iceServers.map((e) => e.toJson()).toList(),
      'ttl': ttl,
      'expires_at': expiresAt,
    };
  }
}
