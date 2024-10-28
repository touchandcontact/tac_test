class ShippingAddress {

  int? id = 0 ;

  int? userId;

  String address = "";

  String city = "";

  String? cap;

  String? country;

  String? nominative;

  String? number;

  String? province;

  int? companyId;


  ShippingAddress();

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json["id"].toString()) ?? 0;
    address = json["address"].toString();
    cap = json["cap"].toString();
    city = json["city"].toString();
    country = json["country"].toString();
    nominative = json["nominative"]?.toString();
    number = json["number"]?.toString();
    province = json["province"].toString();
    userId = int.tryParse(json["userId"].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["userId"] = userId.toString();
    data["companyId"] = null;
    data["address"] = address;
    data["city"] = city;
    data["cap"] = cap;
    data["country"] = country;
    data["nominative"] = nominative;
    data["number"] = number;
    data["province"] = province;
    data["id"] = id.toString();
    return data;
  }
}
