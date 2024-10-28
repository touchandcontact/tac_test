import 'package:tac/models/company_subscription.dart';
import 'package:tac/models/stripe_subscription.dart';

class Company {
  int id = 0;
  String name = "";
  int ownerId = 0;
  String email = "";
  String? description;
  String? city;
  String? country;
  String? telephone;
  String? address;
  String? vat;
  String? website;
  String? color;
  String? logo;
  String? stripeId;
  StripeSubscription? stripeSubscription;
  CompanySubscription? companySubscription;
  bool documentsBlocked = true;
  bool linksBlocked = true;
  bool hasSalesForce = false;
  bool hasHubspot = false;

  Company();

  Company.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    name = json['name'];
    ownerId = int.parse(json["ownerId"].toString());
    email = json["email"];
    description = json["description"];
    city = json["city"];
    country = json["country"];
    telephone = json["telephone"];
    address = json["address"];
    vat = json["vat"];
    website = json["website"];
    color = json["color"];
    logo = json["logo"];
    stripeId = json["stripeId"];
    documentsBlocked = json["documentsBlocked"] ?? true;
    linksBlocked = json["linksBlocked"] ?? true;
    hasSalesForce = json["hasSalesForce"] ?? false;
    hasHubspot = json["hasHubspot"] ?? false;
    stripeSubscription = json["stripeSubscription"] == null
        ? null
        : StripeSubscription.fromJson(json["stripeSubscription"]);
    companySubscription = json["companySubscription"] == null
        ? null
        : CompanySubscription.fromJson(json["companySubscription"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["name"] = name;
    data["ownerId"] = ownerId;
    data["email"] = email;
    data["description"] = description;
    data["city"] = city;
    data["country"] = country;
    data["telephone"] = telephone;
    data["address"] = address;
    data["vat"] = vat;
    data["website"] = website;
    data["color"] = color;
    data["logo"] = logo;
    data["stripeId"] = stripeId;
    data["stripeSubscription"] = stripeSubscription?.toJson();
    data["companySubscription"] = companySubscription?.toJson();
    data["documentsBlocked"] = documentsBlocked;
    data["linksBlocked"] = linksBlocked;
    data["hasSalesForce"] = hasSalesForce;
    data["hasHubspot"] = hasHubspot;
    return data;
  }
}
