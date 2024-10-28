class Folder {
  int id = 0;
  int userId = 0;
  String name = "";
  String? description;
  String? image;
  bool shared = false;
  int countContact = 0;
  DateTime? creationDate;
  bool addHubspot = false;
  bool addSalesForce = false;

  Folder();

  Folder.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    userId = json["userId"] == null ? 0 : int.parse(json["userId"].toString());
    name = json["name"];
    description = json["description"];
    image = json["image"];
    countContact = int.parse(json["countContact"].toString());
    shared = json["shared"].toString().toLowerCase() == "true" ? true : false;
    addHubspot =
        json["addHubspot"].toString().toLowerCase() == "true" ? true : false;
    addSalesForce =
        json["addSalesForce"].toString().toLowerCase() == "true" ? true : false;
    creationDate = DateTime.parse(json["creationDate"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["userId"] = userId;
    data["name"] = name;
    data["image"] = image;
    data["description"] = description;
    data["shared"] = shared;
    data["countContact"] = countContact;
    data["addHubspot"] = addHubspot;
    data["addSalesForce"] = addSalesForce;
    data['creationDate'] = creationDate?.toString();

    return data;
  }
}
