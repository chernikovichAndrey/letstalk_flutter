import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Contact>> getContacts() async {
    final response = await _apiService.get(ApiConstants.contacts);
    final contactsResponse = ContactsResponse.fromJson(response.data);
    return contactsResponse.contacts;
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
