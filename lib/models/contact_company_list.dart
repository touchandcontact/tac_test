import 'contact_company.dart';

class ContactCompanyList {
  int totalCount = 0;
  List<ContactCompany> itemList = <ContactCompany>[];

  ContactCompanyList();

  ContactCompanyList.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'] as int;
    if (json['itemList'] != null) {
      Iterable l = json['itemList'];
      itemList = List<ContactCompany>.from(
          l.map((model) => ContactCompany.fromJson(model)));
    }
  }
}
