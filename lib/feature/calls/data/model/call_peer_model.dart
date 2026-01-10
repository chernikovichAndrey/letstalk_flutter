class CallPeer {
  final int userId;
  final String phone;
  final String name;

  CallPeer({
    required this.userId,
    required this.phone,
    required this.name,
  });

  factory CallPeer.fromJson(Map<String, dynamic> json) {
    return CallPeer(
      userId: json['user_id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone': phone,
      'name': name,
    };
  }
}
