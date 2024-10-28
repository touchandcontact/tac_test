class Contact {
  int id = 0;
  String name = "";
  String? profession;
  String? company;
  String? profileImage;
  int? tacUserId;
  int? externalContactId;
  DateTime? creationDate;

  Contact();

  Contact.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    tacUserId = json["tacUserId"] == null ? null : int.parse(json['tacUserId'].toString());
    externalContactId = json["externalContactId"] == null ? null : int.parse(json['externalContactId'].toString());
    id = int.parse(json['id'].toString());
    name = json['nome'];
    profession = json['professione'];
    company = json['azienda'];
    profileImage = json["profileImage"];
    creationDate = DateTime.parse(json["dataCreazione"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["nome"] = name;
    data['professione'] = profession;
    data['azienda'] = company;
    data['profileImage'] = profileImage;
    data['dataCreazione'] = creationDate.toString();
    data['tacUserId'] = tacUserId;
    data['externalContactId'] = externalContactId;

    return data;
  }
}
