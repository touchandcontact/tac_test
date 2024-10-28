import 'package:decimal/decimal.dart';

class CompanySubscription {
  int companyId = 0;
  int id = 0;
  int? companySubscriptionRangeId;
  String? stripeSubscriptionId;
  Decimal? amount;
  int? period;

  CompanySubscription();

  CompanySubscription.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    companyId = int.parse(json["companyId"].toString());
    companySubscriptionRangeId = json["companySubscriptionRangeId"] == null
        ? null
        : int.parse(json["companySubscriptionRangeId"].toString());
    stripeSubscriptionId = json["stripeSubscriptionId"];
    amount = json["amount"] == null ? null : Decimal.parse(json["amount"]);
    period =
        json["period"] == null ? null : int.parse(json["period"].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data["id"] = id;
    data["companyId"] = companyId;
    data["companySubscriptionRangeId"] = companySubscriptionRangeId;
    data["stripeSubscriptionId"] = stripeSubscriptionId;
    data["amount"] = amount;
    data["period"] = period;

    return data;
  }
}
