import 'package:tac/models/user.dart';
import '../enums/document_or_link_type.dart';

class UserDocumentsOrLinks {
  int id;
  DateTime? creationDate;
  DateTime? lastupdate;
  int userId;
  DocumentOrLinkType type;
  String? name;
  String? description;
  String? link;
  bool shared;
  int? sharedById;
  String icon;
  bool showOnProfile;
  double size;
  User user;

  UserDocumentsOrLinks({
    required this.userId,
    required this.shared,
    required this.showOnProfile,
    required this.icon,
    required this.type,
    required this.size,
    required this.id,
    required this.user,
    this.link,
    this.name,
    this.creationDate,
    this.description,
    this.lastupdate,
    this.sharedById,
  });

  factory UserDocumentsOrLinks.fromJson(Map<String, dynamic> json) {
    return UserDocumentsOrLinks(
      name: json["name"] as String?,
      description: json["description"] as String?,
      link: json["link"] as String?,
      user: json["user"] != null ? User.fromJson(json["user"]) : User(),
      showOnProfile:
          json["showOnProfile"] != null ? json["showOnProfile"] as bool : false,
      shared: json["shared"] != null ? json["shared"] as bool : false,
      size: json["size"] == null ? 0 : double.parse(json["size"].toString()),
      id: json["id"] as int,
      userId: json["userId"] as int,
      icon: json["icon"] as String,
      sharedById: json["sharedById"] as int?,
      lastupdate: json['lastupdate'] == null
          ? null
          : DateTime.parse(json['lastupdate'] as String),
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      type: DocumentOrLinkType.values[int.parse(json['type'].toString())]
    );
  }
}
