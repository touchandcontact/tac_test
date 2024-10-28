class Subscription {
  String? id;
  String? invoiceId;
  String? invoiceStatus;
  String? intentId;
  String? intentStatus;
  String? intentSecret;
  String? intentRedirectUrl;

  Subscription(
      {this.id,
        this.invoiceId,
        this.invoiceStatus,
        this.intentId,
        this.intentStatus,
        this.intentSecret,
        this.intentRedirectUrl
      });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoiceId'];
    invoiceStatus = json['invoiceStatus'];
    intentId = json['intentId'];
    intentStatus = json['intentStatus'];
    intentSecret = json['intentSecret'];
    intentRedirectUrl = json['intentRedirectUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['invoiceId'] = invoiceId;
    data['invoiceStatus'] = invoiceStatus;
    data['intentId'] = intentId;
    data['intentStatus'] = intentStatus;
    data['intentSecret'] = intentSecret;
    data['intentRedirectUrl'] = intentRedirectUrl;
    return data;
  }
}