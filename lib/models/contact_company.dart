class ContactCompany {
  int id = 0;
  String companyName = "";
  String? image = "";
  int contactCount = 0;
  DateTime? creationDate;

  ContactCompany();

  ContactCompany.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    companyName = json['companyName'];
    image = json['image'];
    contactCount = json["contactCount"] == null
        ? 0
        : int.parse(json["contactCount"].toString());
    creationDate = DateTime.parse(json["dataCreazione"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["companyName"] = companyName;
    data['image'] = image;
    data['contactCount'] = contactCount;
    data['dataCreazione'] = creationDate.toString();

    return data;
  }
}
