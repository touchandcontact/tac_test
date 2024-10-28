import 'dart:convert';

import 'external_contact_address.dart';
import 'external_contact_elephone.dart';

class UserContactInfoModel {
  int id;
  int? tacUserId;
  int? userId;
  int? externalContactId;
  String? name;
  String? surname;
  String? profileImage;
  String? profession;
  DateTime? creationDate;
  String? website;
  String? address;
  String? email;
  String? telephone;
  String? vat;
  String? company;
  String? notes;
  String? coverImage;
  List<ExternalContactTelephone>? telephones;
  List<ExternalContactAddress>? addresses;

  bool? isInFavourites = false;

  UserContactInfoModel({required this.id,
    this.tacUserId,
    this.userId,
    this.externalContactId,
    this.name,
    this.surname,
    this.profileImage,
    this.profession,
    this.creationDate,
    this.website,
    this.address,
    this.email,
    this.telephone,
    this.vat,
    this.notes,
    this.coverImage,
    this.company,
    this.telephones,
    this.addresses,
    this.isInFavourites,
  });

  factory UserContactInfoModel.fromJsonInternal(Map<String, dynamic> json) {
    return UserContactInfoModel(
        id: json['id'],
        tacUserId: json['tacUserId'],
        userId: json['userId'],
        externalContactId: json['externalContactId'],
        name: json['name'],
        surname: json['surname'],
        profileImage: json['profileImage'],
        profession: json['profession'],
        creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
        website: json['website'],
        address: json['address'],
        email: json['email'],
        telephone: json['telephone'],
        vat: json['vat'],
       company: json['company'],
        notes: json['notes'],
       coverImage: json['coverImage'],
      isInFavourites: json['isInFavourites'] ?? false,
    );
  }

  Map<String, dynamic> toJsonInternal() {
    return {
      "id": id,
      "tacUserId": tacUserId,
      "userId": userId,
      "externalContactId": externalContactId,
      "name": name,
      "surname": surname,
      "profileImage": profileImage,
      "profession": profession,
      "creationDate": creationDate.toString(),
      "website": website,
      "address": address,
      "email": email,
      "telephone": telephone,
      "vat": vat,
      "company": company,
      "coverImage": coverImage,
      "notes": notes,
      "isInFavourites": isInFavourites,
    };
  }

  factory UserContactInfoModel.fromJsonExternal(Map<String, dynamic> json) {
    return UserContactInfoModel(
        id: json['id'],
        userId: json['userId'],
        externalContactId: json['externalContactId'],
        name: json['name'],
        surname: json['surname'],
        profileImage: json['profileImage'],
        profession: json['profession'],
        creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : null,
        website: json['website'],
        address: json['address'],
        email: json['email'],
        telephone: json['telephone'],
        vat: json['vat'],
       company: json['company'],
        notes: json['notes'],
      isInFavourites: json['isInFavourites'] ?? false,
       coverImage: json['coverImage'],
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

  Map<String, dynamic> toJsonExternal() {
    return {
      "id": id,
      "userId": userId,
      "externalContactId": externalContactId,
      "name": name,
      "surname": surname,
      "profileImage": profileImage,
      "profession": profession,
      "creationDate": creationDate.toString(),
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
      "isInFavourites": isInFavourites,
    };
  }

  UserContactInfoModel clone() {
    final String jsonString = json.encode(toJsonExternal());
    final jsonResponse = json.decode(jsonString);
    return UserContactInfoModel.fromJsonExternal(jsonResponse as Map<String, dynamic>);
  }


}
