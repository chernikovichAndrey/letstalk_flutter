import 'package:lets_talk/feature/contacts/data/model/contact_model.dart';

abstract class AddContactRepository {
  Future<void> addContacts(Contact contact);
}
