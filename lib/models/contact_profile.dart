import 'dart:convert';

class ContactProfile {
  int id = 0;
  String name = "";
  String surname = "";
  String email = "";
  String? profileImage;
  String? coverImage;
  String? company;
  String? department;
  String? profession;
  String? telephone;
  String? address;
  String? vat;
  String? website;
  String? notes;
  List<String>? tags;

  ContactProfile();

  ContactProfile.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    surname = json['surname'];
    email = json["email"];
    profileImage = json['profileImage'];
    coverImage = json['coverImage'];
    company = json['company'];
    department = json['department'];
    profession = json['profession'];
    telephone = json["telephone"];
    address = json["address"];
    vat = json["vat"];
    website = json["website"];
    notes = json['notes'];
    tags = json["tags"] == null
        ? null
        : (json['tags'] as List).map((item) => item as String).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["name"] = name;
    data["surname"] = surname;
    data["email"] = email;
    data["profileImage"] = profileImage;
    data["coverImage"] = coverImage;
    data["company"] = company;
    data["department"] = department;
    data["profession"] = profession;
    data["telephone2"] = telephone;
    data["telephone"] = telephone;
    data["address"] = address;
    data["vat"] = vat;
    data["website"] = website;
    data["notes"] = notes;
    data["tags"] = jsonEncode(tags);

    return data;
  }
}
