class ExternalContactTelephone {
  int id = 0;
  int contactId = 0;
  String? telephone;
  DateTime creationDate = DateTime.now();
  DateTime lastUpdate = DateTime.now();

  ExternalContactTelephone();

  ExternalContactTelephone.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    contactId = int.parse(json["contactId"].toString());
    telephone = json["telephone"];
    creationDate = DateTime.parse(json["creationDate"] as String);
    lastUpdate = DateTime.parse(json["lastUpdate"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["contactId"] = contactId;
    data["telephone"] = telephone;
    data["creationDate"] = creationDate.toString();
    data["lastUpdate"] = lastUpdate.toString();

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalContactTelephone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          contactId == other.contactId &&
          telephone == other.telephone &&
          creationDate == other.creationDate &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode =>
      id.hashCode ^
      contactId.hashCode ^
      telephone.hashCode ^
      creationDate.hashCode ^
      lastUpdate.hashCode;
}
