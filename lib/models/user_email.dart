class UserEmail {
  int id = 0;
  int userId = 0;
  String? email;

  UserEmail();

  UserEmail.fromJson(Map<String, dynamic> json) {
    id = int.parse(json["id"].toString());
    userId = int.parse(json["userId"].toString());
    email = json["email"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["userId"] = userId;
    data["email"] = email;

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEmail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          email == other.email;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      email.hashCode;
}
