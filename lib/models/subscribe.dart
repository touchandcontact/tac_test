class Subscribe {
  String? customer;
  String? paymentMethd;
  String? price;
  String? currency;
  int? quantity = 1;
  String coupon = "";
  String? transactionId;

  Subscribe(
      {
        this.customer,
        this.paymentMethd,
        this.price,
        this.currency,
        this.quantity = 1,
        this.transactionId = "",
        this.coupon = ""});

  Subscribe.fromJson(Map<String, dynamic> json) {
    customer = json['customer'];
    paymentMethd = json['paymentMethd'];
    price = json['price'];
    currency = json['currency'];
    quantity = json['quantity'] ?? 1;
    coupon = json['coupon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer'] = customer;
    data['paymentMethd'] = paymentMethd;
    data['price'] = price;
    data['currency'] = currency;
    data['quantity'] = quantity;
    data['coupon'] = coupon;
    data['transactionId'] = transactionId;
    return data;
  }
}