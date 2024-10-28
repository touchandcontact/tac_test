class UserTelephone {
  int id = 0;
  int userId = 0;
  String? telephone;
  DateTime creationDate = DateTime.now();
  DateTime lastUpdate = DateTime.now();

  UserTelephone();

  UserTelephone.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    userId = int.parse(json["userId"].toString());
    telephone = json["telephone"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["userId"] = userId;
    data["telephone"] = telephone;
    data["creationDate"] = creationDate.toString();
    data["lastUpdate"] = lastUpdate.toString();

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTelephone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          telephone == other.telephone &&
          creationDate == other.creationDate &&
          lastUpdate == other.lastUpdate;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      telephone.hashCode ^
      creationDate.hashCode ^
      lastUpdate.hashCode;
}
