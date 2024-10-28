class FolderInsert {
  int id = 0;
  int userid = 0;
  String name = "";
  String? image;
  String? description;
  bool shared = false;
  bool addHubspot = false;
  bool addSalesForce = false;

  FolderInsert();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["userId"] = userid;
    data["name"] = name;
    data["shared"] = shared;
    data["addSalesForce"] = addSalesForce;
    data["addHubspot"] = addHubspot;
    data["image"] = image;
    data['description'] = description;

    return data;
  }
}
