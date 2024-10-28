class Tag {
  int id = 0;
  int userContactId = 0;
  String tag = "";

  Tag();

  Tag.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    userContactId = int.parse(json["userContactId"].toString());
    tag = json["tag"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userContactId": userContactId,
      "tag": tag,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id;
}
