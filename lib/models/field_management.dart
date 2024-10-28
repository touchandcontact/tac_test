class FieldManagement {
  String fieldName = "";
  bool canEdit = true;
  bool fullLocked = false;

  FieldManagement();

  FieldManagement.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    canEdit = json["canEdit"] as bool;
    fullLocked = json["fullLocked"] as bool;
  }
}
