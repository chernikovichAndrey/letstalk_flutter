import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts();
}
