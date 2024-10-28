import 'dart:convert';

import 'external_contact_address.dart';
import 'external_contact_elephone.dart';

class OcrContactDto {
  int id;
  int? userId;
  int? externalContactId;
  String? name;
  String? surname;
  String? profileImage;
  String? coverImage;
  String? profession;
  DateTime? creationDate;
  String? website;
  String? address;
  String? email;
  String? telephone;
  String? vat;
  String? company;
  String? notes;
  List<ExternalContactTelephone>? telephones;
  List<ExternalContactAddress>? addresses;

  OcrContactDto(
      {
        required this.id,
        this.externalContactId,
        this.notes,
        this.name,
        this.surname,
        this.email,
        this.telephone,
        this.profession,
        this.vat,
        this.address,
        this.profileImage,
        this.coverImage,
        this.website,
        this.telephones,
        this.addresses,
        this.creationDate,
        this.company,
        this.userId,
      });

  factory OcrContactDto.fromJson(Map<String, dynamic> json) {
    return OcrContactDto(
      id: json["id"],
      name: json["name"] as String?,
      surname: json["surname"] as String?,
      email: json["email"] as String?,
      telephone: json["telephone"] as String?,
      profession: json["profession"] as String?,
      vat: json["vat"] as String?,
      address: json["address"] as String?,
      profileImage: json["profileImage"] as String?,
      coverImage: json["coverImage"] as String?,
      website: json["website"] as String?,
      company: json["company"] as String?,
      externalContactId: json["externalContactId"] as int?,
      notes: json["notes"] as String?,
      userId: json["userId"] as int?,
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
      addresses: json['addresses']  != null ? (json['addresses'] as List<dynamic>?)
          ?.map(
              (e) => ExternalContactAddress.fromJson(e as Map<String, dynamic>))
          .toList() : null,
      telephones: json['telephones']  != null ? (json['telephones'] as List<dynamic>?)
          ?.map(
              (e) => ExternalContactTelephone.fromJson(e as Map<String, dynamic>))
          .toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "externalContactId": externalContactId,
      "name": name,
      "surname": surname,
      "profileImage": profileImage,
      "profession": profession,
      "creationDate": creationDate?.toString(),
      "website": website,
      "address": address,
      "email": email,
      "telephone": telephone,
      "vat": vat,
      "company": company,
      "coverImage": coverImage,
      "notes": notes,
      "telephones": telephones,
      "addresses": addresses,
    };
  }

  OcrContactDto clone() {
    final String jsonString = json.encode(toJson());
    final jsonResponse = json.decode(jsonString);
    return OcrContactDto.fromJson(jsonResponse as Map<String, dynamic>);
  }

}
