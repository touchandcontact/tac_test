import 'package:tac/enums/document_or_link_type.dart';

class ElementModel {
  int id = 0;
  int userId = 0;
  DocumentOrLinkType type = DocumentOrLinkType.document;
  String name = "";
  String description = "";
  String link = "";
  bool shared = false;
  int? sharedById;
  String icon = "";
  bool showOnProfile = false;
  DateTime? creationDate;
  DateTime? lastUpdate;
  double size = 0;

  ElementModel();

  ElementModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    userId = json['userId'] != null ? int.parse(json['userId'].toString()) : 0;
    type = DocumentOrLinkType.values[int.parse(json['type'].toString())];
    name = json['name'];
    description = json["description"];
    link = json["link"];
    shared = json["shared"] as bool;
    sharedById = json["sharedById"] == null
        ? null
        : int.parse(json["sharedById"].toString());
    icon = json["icon"];
    showOnProfile = json["showOnProfile"] != null ? json["showOnProfile"] as bool : false;
    creationDate = DateTime.parse(json["creationDate"] as String);
    lastUpdate = DateTime.parse(json["lastUpdate"] as String);
    size = json['size'] != null ? double.parse(json['size'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["userId"] = userId;
    data["type"] = type.index;
    data["name"] = name;
    data["description"] = description;
    data["link"] = link;
    data["shared"] = shared;
    data["sharedById"] = sharedById;
    data['icon'] = icon;
    data["showOnProfile"] = showOnProfile;
    data['creationDate'] = creationDate.toString();
    data['lastUpdate'] = lastUpdate.toString();
    data['size'] = size;

    return data;
  }
}
