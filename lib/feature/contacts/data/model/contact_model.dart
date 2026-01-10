class Contact {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String address;
  final String imageUrl;
  final bool isRegistered;
  final int? registeredUserId;

  Contact({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.address,
    required this.imageUrl,
    required this.isRegistered,
    this.registeredUserId,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isRegistered: (json['is_registered'] as int? ?? 0) == 1,
      registeredUserId: json['registered_user_id'] as int?,
    );
  }
}

class ContactsResponse {
  final String status;
  final List<Contact> contacts;
  final int count;

  ContactsResponse({
    required this.status,
    required this.contacts,
    required this.count,
  });

  factory ContactsResponse.fromJson(Map<String, dynamic> json) {
    return ContactsResponse(
      status: json['status'] as String? ?? '',
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => Contact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}
