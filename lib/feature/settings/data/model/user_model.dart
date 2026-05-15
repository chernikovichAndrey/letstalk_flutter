class UserModel {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? address;
  final String? username;
  final String? avatar;
  final String? avatarUrl;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.address,
    this.username,
    this.avatar,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'address': address,
      'username': username,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
