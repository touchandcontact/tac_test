import 'dart:convert';

import 'package:tac/models/shipping.dart';

class BillingAddress {

  int? id;

  ShippingAddress ? shipmentAddress;

  int? shipmentAddressId;

  int? userId;

  String? address;

  String? city;

  String? cap;

  String? country;

  String? province;

  String? nominative;

  String? number;
  String? uniqueCode;
  String? businessName;
  String? vat;

  BillingAddress();

  BillingAddress.fromJson(Map<String, dynamic> json) {
    id = json["id"] as int;
    address = json["address"].toString();
    cap = json["cap"].toString();
    city = json["city"].toString();
    country = json["country"].toString();
    nominative = json["nominative"]?.toString();
    uniqueCode = json["uniqueCode"]?.toString();
    businessName = json["businessName"]?.toString();
    vat = json["vat"]?.toString();
    number = json["number"].toString();
    province = json["province"].toString();
    userId = int.tryParse(json["userId"].toString()) ?? 0;
    shipmentAddress = json["shipmentAddress"] != null ? ShippingAddress.fromJson(json["shipmentAddress"]) : null;
    shipmentAddressId = json["shipmentAddressId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["shipmentAddressId"] = shipmentAddressId.toString();
    data["address"] = address;
    data["cap"] = cap;
    data["city"] = city;
    data["country"] = country;
    data["nominative"] = nominative;
    data["number"] = number;
    data["province"] = province;
    data["userId"] = userId;
    data["id"] = id;
    data["uniqueCode"] = uniqueCode;
    data["businessName"] = businessName;
    data["vat"] = vat;
    return data;
  }

  Map<String, dynamic> toJsonClone() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["shipmentAddressId"] = shipmentAddressId.toString();
    data["shipmentAddress"] = shipmentAddress;
    data["address"] = address;
    data["cap"] = cap;
    data["city"] = city;
    data["country"] = country;
    data["nominative"] = nominative;
    data["number"] = number;
    data["province"] = province;
    data["userId"] = userId;
    data["id"] = id;
    return data;
  }

  BillingAddress.fromJsonClone(Map<String, dynamic> json) {
    address = json["address"].toString();
    cap = json["cap"].toString();
    city = json["city"].toString();
    country = json["country"].toString();
    nominative = json["nominative"].toString();
    number = json["number"].toString();
    province = json["province"].toString();
    userId = json["userId"] != null ? json["userId"] as int : null;
    shipmentAddress = json["shipmentAddress"] != null ? ShippingAddress.fromJson(json["shipmentAddress"]) : null;
    shipmentAddressId = json["shipmentAddressId"] != null ? int.tryParse(json["shipmentAddressId"]) : null;
    id = json["id"];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingAddress &&
          runtimeType == other.runtimeType &&
          shipmentAddress == other.shipmentAddress &&
          shipmentAddressId == other.shipmentAddressId &&
          userId == other.userId &&
          address == other.address &&
          city == other.city &&
          cap == other.cap &&
          country == other.country &&
          province == other.province &&
          nominative == other.nominative &&
          id == other.id &&
          number == other.number;

  @override
  int get hashCode =>
      shipmentAddress.hashCode ^
      shipmentAddressId.hashCode ^
      userId.hashCode ^
      address.hashCode ^
      city.hashCode ^
      cap.hashCode ^
      country.hashCode ^
      province.hashCode ^
      nominative.hashCode ^
      id.hashCode ^
      number.hashCode;


  BillingAddress clone() {
    final String jsonString = json.encode(toJsonClone());
    final jsonResponse = json.decode(jsonString);
    return BillingAddress.fromJsonClone(jsonResponse as Map<String, dynamic>);
  }
}
