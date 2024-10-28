import 'package:tac/extentions/pars_bool.dart';
import 'package:tac/models/company.dart';
import 'package:tac/models/stripe_subscription.dart';

class User {
  int id = 0;
  int tacUserId = 0;
  String identifier = "";
  String? email;
  String? name;
  String? surname;
  List<String>? roles;
  String? telephone;
  int? companyId;
  int? departmentId;
  String? profession;
  String? vat;
  String? address;
  String? stripeId;
  String? profileImage;
  String? website;
  String? departmentName;
  bool enabled = false;
  int? subscriptionType;
  DateTime? creationDate;
  DateTime? lastUpdate;
  Company? company;
  String? companyName;
  String? coverImage;
  String accessEmail = "";
  bool isCompanyPremium = false;
  bool subscriptionGifted = false;
  StripeSubscription? stripeSubscription;
  User();

  User.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    tacUserId = int.parse(json['tacUserId'].toString());
    identifier = json["identifier"].toString();
    accessEmail = json["accessEmail"].toString();
    enabled = json["enabled"].toString() == "true" ? true : false;
    roles = json["roles"] != null
        ? (json["roles"] as List<dynamic>).cast<String>()
        : null;
    email = json['email'];
    name = json['name'];
    surname = json['surname'];
    creationDate = DateTime.parse(json["creationDate"] as String);
    lastUpdate = DateTime.parse(json["lastUpdate"] as String);
    companyId = json["companyId"] != null
        ? int.parse(json["companyId"].toString())
        : null;
    telephone = json["telephone"];
    departmentId = json["departmentId"] != null
        ? int.parse(json["departmentId"].toString())
        : null;
    profession = json["profession"];
    vat = json["vat"];
    address = json["address"];
    stripeId = json["stripeid"] ?? json["stripeId"];
    profileImage = json["profileImage"];
    website = json["website"];
    departmentName = json["departmentName"];
    coverImage = json["coverImage"];
    subscriptionType = json["subscriptionType"] != null
        ? int.parse(json["subscriptionType"].toString())
        : null;
    stripeSubscription = json["stripeSubscription"] != null
        ? StripeSubscription.fromJson(json["stripeSubscription"])
        : null;
    company =
        json["company"] == null ? null : Company.fromJson(json["company"]);
    isCompanyPremium =
        companyId != null && company?.stripeSubscription?.status == "active";
    companyName = json["companyName"];
    subscriptionGifted = json["subscriptionGifted"] == null ? false : json["subscriptionGifted"].toString().parseBool();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["tacUserId"] = tacUserId;
    data["identifier"] = identifier;
    data["enabled"] = enabled;
    data["companyId"] = companyId;
    data["accessEmail"] = accessEmail;
    data["stripeid"] = stripeId;
    data["address"] = address;
    data["vat"] = vat;
    data["subscriptionType"] = subscriptionType;
    data["profileImage"] = profileImage;
    data["departmentId"] = departmentId;
    data["departmentName"] = departmentName;
    data["website"] = website;
    data["lastUpdate"] = lastUpdate.toString();
    data["creationDate"] = creationDate.toString();
    data["telephone"] = telephone;
    data["enabled"] = enabled;
    data["telephone"] = telephone;
    data["profession"] = profession;
    data["email"] = email;
    data['name'] = name;
    data["surname"] = surname;
    data["roles"] = roles;
    data["company"] = company;
    data["coverImage"] = coverImage;
    data["isCompanyPremium"] = isCompanyPremium;
    data["companyName"] = companyName;
    data["subscriptionGifted"] = subscriptionGifted;

    return data;
  }
}
