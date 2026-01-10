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
}
