import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../../feature/contacts/data/model/contact_model.dart';

class PhoneContactsService {
  static final PhoneContactsService _instance = PhoneContactsService._internal();
  factory PhoneContactsService() => _instance;
  PhoneContactsService._internal();

  Future<bool> requestPermission() async {
    return await fc.FlutterContacts.requestPermission();
  }

  Future<List<Contact>> getPhoneContacts() async {
    if (!await fc.FlutterContacts.requestPermission()) {
      return [];
    }

    final contacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    return contacts
        .where((c) => c.phones.isNotEmpty)
        .map((c) => _mapToContact(c))
        .toList();
  }

  Contact _mapToContact(fc.Contact contact) {
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final email = contact.emails.isNotEmpty ? contact.emails.first.address : '';
    final address =
        contact.addresses.isNotEmpty ? contact.addresses.first.address : '';
    
    // Construct full name if display name is empty
    String fullName = contact.displayName;
    if (fullName.isEmpty) {
      fullName = [contact.name.first, contact.name.last].where((s) => s.isNotEmpty).join(' ');
    }
    
    return Contact(
      phone: phone,
      firstName: contact.name.first,
      lastName: contact.name.last,
      fullName: fullName,
      email: email.isNotEmpty ? email : null,
      address: address.isNotEmpty ? address : null,
      imageUrl: null, // Photo upload not implemented yet
    );
  }
}
