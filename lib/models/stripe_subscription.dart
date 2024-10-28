class StripeSubscription {
  String? id;
  String? created;
  String? startDate;
  String? defaultPaymentMethodId;
  String? status;
  String? paymentIntentSecret;

  StripeSubscription(
      {this.id,
        this.created,
        this.startDate,
        this.defaultPaymentMethodId,
        this.status,
        this.paymentIntentSecret});

  StripeSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    startDate = json['startDate'];
    defaultPaymentMethodId = json['defaultPaymentMethodId'];
    status = json['status'];
    paymentIntentSecret = json['paymentIntentSecret'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['created'] = created;
    data['startDate'] = startDate;
    data['defaultPaymentMethodId'] = defaultPaymentMethodId;
    data['status'] = status;
    data['paymentIntentSecret'] = paymentIntentSecret;
    return data;
  }
}