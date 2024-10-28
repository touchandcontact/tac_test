
import 'package:tac/models/shipping.dart';

import 'billing.dart';

class StripeCompleteSubscriptionForMobileDto {
  String? id;
  String? productName;
  DateTime created = DateTime.now();
  DateTime startDate = DateTime.now();
  int? daysUntilDue;
  String? defaultPaymentMethodId;
  String? status;
  String? paymentIntentSecret;
  BillingAddress? billingAddress;
  ShippingAddress? shipmentAddress;
  double? priceAmount;
  String? pricePeriod;

  StripeCompleteSubscriptionForMobileDto();

  StripeCompleteSubscriptionForMobileDto.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    created = DateTime.parse(json["created"] as String);
    startDate = DateTime.parse(json["startDate"] as String);
    daysUntilDue = json["departmentId"] != null
        ? int.parse(json["departmentId"].toString())
        : null;
    defaultPaymentMethodId = json['defaultPaymentMethodId'] as String?;
    status = json['status'] as String?;
    paymentIntentSecret = json['paymentIntentSecret'] as String?;
    billingAddress = json["billingAddress"] != null
        ? BillingAddress.fromJson(json["billingAddress"])
        : null;
    shipmentAddress = json["shipmentAddress"] != null
        ? ShippingAddress.fromJson(json["shipmentAddress"])
        : null;
    pricePeriod = json['pricePeriod'] as String?;
    priceAmount = json['priceAmount'].toDouble();
    productName = json['productName'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["created"] = created.toString();
    data["startDate"] = startDate.toString();
    data["daysUntilDue"] = daysUntilDue;
    data["defaultPaymentMethodId"] = defaultPaymentMethodId;
    data["status"] = status;
    data["paymentIntentSecret"] = paymentIntentSecret;
    data["billingAddress"] = billingAddress;
    data["shipmentAddress"] = shipmentAddress;
    data["priceAmount"] = priceAmount;
    data["pricePeriod"] = pricePeriod;
    data["productName"] = productName;

    return data;
  }
}
