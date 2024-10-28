import 'contact.dart';

class ContactList {
  int totalCount = 0;
  List<Contact> userContactlist = <Contact>[];

  ContactList();

  ContactList.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'] as int;
    if (json['userContactList'] != null) {
      Iterable l = json['userContactList'];
      userContactlist =
          List<Contact>.from(l.map((model) => Contact.fromJson(model)));
    }
  }
}
