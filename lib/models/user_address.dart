class UserAddress {
  int id = 0;
  int userId = 0;
  String? address;
  DateTime creationDate = DateTime.now();
  DateTime lastUpdate = DateTime.now();

  UserAddress();

  UserAddress.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    userId = int.parse(json["userId"].toString());
    address = json["address"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["contactId"] = userId;
    data["address"] = address;
    data["creationDate"] = creationDate.toString();
    data["lastUpdate"] = lastUpdate.toString();

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          address == other.address &&
          creationDate == other.creationDate &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      address.hashCode ^
      creationDate.hashCode ^
      lastUpdate.hashCode;
}
