import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';
import 'package:lets_talk/feature/contacts/domain/repository/add_contact_repository.dart';

class AddContactRepositoryImpl implements AddContactRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<void> addContacts(Contact contact) async {
    await _apiService.post(
      ApiConstants.addContact,
      data: contact.toJson(),
    );
  }
}
