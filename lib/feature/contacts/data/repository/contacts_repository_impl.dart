import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/contacts_repository.dart';

@LazySingleton(as: ContactsRepository)
class ContactsRepositoryImpl implements ContactsRepository {
  final ApiService _apiService;

  ContactsRepositoryImpl(this._apiService);

  @override
  Future<List<Contact>> getContacts() async {
    final response = await _apiService.get(ApiConstants.contacts);
    final contactsResponse = ContactsResponse.fromJson(response.data);
    final contacts = contactsResponse.contacts;
    contacts.sort((a, b) {
      if (a.isRegistered == b.isRegistered) return 0;
      return a.isRegistered ? -1 : 1;
    });
    return contacts;
  }

  @override
  Future<void> deleteContacts(int id) async {
    await _apiService.delete(
      '${ApiConstants.contacts}/$id',
    );
  }

  @override
  Future<void> uploadPhoneContacts(List<Contact> contacts) async {
    await _apiService.post(
      ApiConstants.contacts,
      data: {
        'contacts': contacts.map((c) => c.toJson()).toList(),
      },
    );
  }
}
