import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/contacts/data/model/contact_model.dart';

@singleton
class PhoneContactsService {
  static const _deletedContactsKey = 'deleted_phone_contacts';

  final Map<void Function(), StreamSubscription<dynamic>> _subscriptions = {};

  PhoneContactsService();

  void addListener(void Function() listener) {
    _subscriptions[listener] =
        fc.FlutterContacts.onDatabaseChange.listen((_) => listener());
  }

  void removeListener(void Function() listener) {
    _subscriptions.remove(listener)?.cancel();
  }

  Future<bool> requestPermission() async {
    final status = await fc.FlutterContacts.permissions
        .request(fc.PermissionType.readWrite);
    return status == fc.PermissionStatus.granted;
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
    final status = await fc.FlutterContacts.permissions
        .request(fc.PermissionType.readWrite);
    if (status != fc.PermissionStatus.granted) return [];

    final contacts = await fc.FlutterContacts.getAll(
      properties: {
        fc.ContactProperty.name,
        fc.ContactProperty.phone,
        fc.ContactProperty.email,
        fc.ContactProperty.address,
      },
    );

    final prefs = await SharedPreferences.getInstance();
    final excludedSet =
        (prefs.getStringList(_deletedContactsKey) ?? []).toSet();

    return contacts
        .where((c) {
          if (c.phones.isEmpty) return false;
          final normalized = _normalizePhone(c.phones.first.number);
          return !excludedSet.contains(normalized);
        })
        .map(_mapToContact)
        .toList();
  }

  Contact _mapToContact(fc.Contact contact) {
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final email =
        contact.emails.isNotEmpty ? contact.emails.first.address : '';
    final address = contact.addresses.isNotEmpty
        ? (contact.addresses.first.formatted ?? '')
        : '';

    String fullName = contact.displayName ?? '';
    if (fullName.isEmpty) {
      final first = contact.name?.first ?? '';
      final last = contact.name?.last ?? '';
      fullName = [first, last].where((s) => s.isNotEmpty).join(' ');
    }

    return Contact(
      phone: phone,
      firstName: contact.name?.first ?? '',
      lastName: contact.name?.last ?? '',
      fullName: fullName,
      email: email.isNotEmpty ? email : null,
      address: address.isNotEmpty ? address : null,
      imageUrl: null,
    );
  }
}
