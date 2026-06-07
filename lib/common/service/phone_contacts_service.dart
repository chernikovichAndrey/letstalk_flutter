import 'package:injectable/injectable.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/contacts/data/model/contact_model.dart';

@singleton
class PhoneContactsService {
  static const _deletedContactsKey = 'deleted_phone_contacts';

  PhoneContactsService();

  void addListener(void Function() listener) {
    fc.FlutterContacts.addListener(listener);
  }

  void removeListener(void Function() listener) {
    fc.FlutterContacts.removeListener(listener);
  }

  Future<bool> requestPermission() async {
    return await fc.FlutterContacts.requestPermission();
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Future<void> addToExclusionList(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;
    
    final list = prefs.getStringList(_deletedContactsKey) ?? [];
    if (!list.contains(normalized)) {
      list.add(normalized);
      await prefs.setStringList(_deletedContactsKey, list);
    }
  }

  Future<void> removeFromExclusionList(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;
    
    final list = prefs.getStringList(_deletedContactsKey) ?? [];
    if (list.contains(normalized)) {
      list.remove(normalized);
      await prefs.setStringList(_deletedContactsKey, list);
    }
  }

  Future<List<Contact>> getPhoneContacts() async {
    if (!await fc.FlutterContacts.requestPermission()) {
      return [];
    }

    final contacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    final prefs = await SharedPreferences.getInstance();
    final excludedList = prefs.getStringList(_deletedContactsKey) ?? [];
    final excludedSet = excludedList.toSet();

    return contacts
        .where((c) {
          if (c.phones.isEmpty) return false;
          final normalized = _normalizePhone(c.phones.first.number);
          return !excludedSet.contains(normalized);
        })
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
