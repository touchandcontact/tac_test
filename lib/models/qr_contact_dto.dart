import 'package:tac/models/user_address.dart';
import 'package:tac/models/user_telephone.dart';

class QrContactDto {
  int id = 0;
  int tacUserId = 0;
  String? name;
  String? surname;
  String? identifier;
  String? email;
  String? password;
  List<String>? roles;
  String? telephone;
  int? companyId;
  int? departmentId;
  String? profession;
  String? vat;
  String? address;
  String? stripeId;
  String? profileImage;
  String? coverImage;
  String? website;
  String? departmentName;
  String? companyName;
  List<UserTelephone>? telephones;
  List<UserAddress>? addresses;

  QrContactDto(
  {
    required this.id,
    required this.tacUserId,
    this.name,
    this.surname,
    this.identifier,
    this.email,
    this.password,
    this.roles,
    this.telephone,
    this.companyId,
    this.departmentId,
    this.profession,
    this.vat,
    this.address,
    this.stripeId,
    this.profileImage,
    this.coverImage,
    this.website,
    this.departmentName,
    this.companyName,
    this.telephones,
    this.addresses,
  });

  factory QrContactDto.fromJson(Map<String, dynamic> json) {
    return QrContactDto(
      id: json["id"],
      tacUserId: json["tacUserId"],
      name: json["name"] as String?,
      surname: json["surname"] as String?,
      identifier: json["identifier"] as String?,
      email: json["email"] as String?,
      password: json["password"] as String?,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          const [],
      telephone: json["telephone"] as String?,
      companyId: json["companyId"] as int?,
      departmentId: json["departmentId"] as int?,
      profession: json["profession"] as String?,
      vat: json["vat"] as String?,
      address: json["address"] as String?,
      stripeId: json["stripeId"] as String?,
      profileImage: json["profileImage"] as String?,
      coverImage: json["coverImage"] as String?,
      website: json["website"] as String?,
      departmentName: json["departmentName"] as String?,
      companyName: json["companyName"] as String?,
      addresses: json['addresses']  != null ? (json['addresses'] as List<dynamic>?)
          ?.map(
              (e) => UserAddress.fromJson(e as Map<String, dynamic>))
          .toList() : null,
      telephones: json['telephones']  != null ? (json['telephones'] as List<dynamic>?)
          ?.map(
              (e) => UserTelephone.fromJson(e as Map<String, dynamic>))
          .toList() : null,
    );
  }

}
