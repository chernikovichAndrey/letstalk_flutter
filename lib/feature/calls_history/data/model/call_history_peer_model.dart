class CallHistoryPeer {
  final int userId;
  final String phone;
  final String name;
  final String? avatar;

  CallHistoryPeer({
    required this.userId,
    required this.phone,
    required this.name,
    this.avatar,
  });

  factory CallHistoryPeer.fromJson(Map<String, dynamic> json) {
    return CallHistoryPeer(
      userId: json['user_id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone': phone,
      'name': name,
      'avatar': avatar,
    };
  }
}
