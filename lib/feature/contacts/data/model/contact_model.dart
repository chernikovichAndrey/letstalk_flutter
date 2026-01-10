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
      id: int.tryParse(json['id'].toString()) ?? 0,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isRegistered: (int.tryParse(json['is_registered'].toString()) ?? 0) == 1,
      registeredUserId: json['registered_user_id'] != null 
          ? int.tryParse(json['registered_user_id'].toString()) 
          : null,
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
      count: int.tryParse(json['count'].toString()) ?? 0,
    );
  }
}
