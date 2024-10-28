class ExternalContactAddress {
  int id = 0;
  int contactId = 0;
  String? address;
  DateTime creationDate = DateTime.now();
  DateTime lastUpdate = DateTime.now();

  ExternalContactAddress();

  ExternalContactAddress.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    contactId = int.parse(json["contactId"].toString());
    address = json["address"];
    creationDate = DateTime.parse(json["creationDate"] as String);
    lastUpdate = DateTime.parse(json["lastUpdate"] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["contactId"] = contactId;
    data["address"] = address;
    data["creationDate"] = creationDate.toString();
    data["lastUpdate"] = lastUpdate.toString();

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalContactAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          contactId == other.contactId &&
          address == other.address &&
          creationDate == other.creationDate &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode =>
      id.hashCode ^
      contactId.hashCode ^
      address.hashCode ^
      creationDate.hashCode ^
      lastUpdate.hashCode;
}
