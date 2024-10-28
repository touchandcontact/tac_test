class ExternalContact {
  int id = 0;
  String name = "";
  String surname = "";
  String email = "";
  String? profileImage;
  String? company;
  String? businessCardImage;
  String? profession;
  String? website;
  String? address;
  String? telephone;
  String? telephone2;
  String? vat;
  DateTime? creationDate;

  ExternalContact();

  ExternalContact.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    surname = json["surname"];
    email = json["email"];
    profileImage = json["profileImage"];
    businessCardImage = json["businessCardImage"];
    website = json["website"];
    address = json["address"];
    telephone = json["telephone"];
    telephone2 = json["telephone2"];
    profession = json['profession'];
    vat = json["vat"];
    company = json["company"];
    creationDate = DateTime.parse(json["creationDate"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["name"] = name;
    data["surname"] = surname;
    data["email"] = email;
    data["profileImage"] = profileImage;
    data["businessCardImage"] = businessCardImage;
    data['profession'] = profession;
    data["website"] = website;
    data["address"] = address;
    data["telephone"] = telephone;
    data["telephone2"] = telephone2;
    data['creationDate'] = creationDate.toString();
    data["vat"] = vat;
    data["company"] = company;

    return data;
  }
}
