import 'dart:convert';

class PaymentListCard {
  String? id;
  String? object;
  CardDetail? card;
  BillingDetails? billingDetails;
  int? created;
  String? customer;
  String? type;

  PaymentListCard(

      {this.id,
        this.object,
        this.card,
        this.created,
        this.customer,
        this.type,
        this.billingDetails
      });

  PaymentListCard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    card = json['card'] != null ?  CardDetail.fromJson(json['card']) : null;
    billingDetails = json['billing_details'] != null ?  BillingDetails.fromJson(json['billing_details']) : null;
    created = json['created'];
    customer = json['customer'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['object'] = object;
    if (card != null) {
      data['card'] = card!.toJson();
    }
    if (billingDetails != null) {
      data['billing_details'] = billingDetails!.toJson();
    }
    data['created'] = created;
    data['customer'] = customer;
    data['type'] = type;
    return data;
  }

  PaymentListCard clone() {
    final String jsonString = json.encode(toJson());
    final jsonResponse = json.decode(jsonString);
    return PaymentListCard.fromJson(jsonResponse as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentListCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          card == other.card &&
          billingDetails == other.billingDetails &&
          created == other.created &&
          customer == other.customer &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      object.hashCode ^
      card.hashCode ^
      billingDetails.hashCode ^
      created.hashCode ^
      customer.hashCode ^
      type.hashCode;
}

class CardDetail {
  String? brand;
  String? country;
  int? expMonth;
  int? expYear;
  String? fingerprint;
  String? funding;
  String? last4;
  Networks? networks;
  ThreeDSecureUsage? threeDSecureUsage;
  Wallet? wallet;
  CardDetail(
      {this.brand,
        this.country,
        this.expMonth,
        this.expYear,
        this.fingerprint,
        this.funding,
        this.last4,
        this.networks,
        this.threeDSecureUsage,
        this.wallet,
      });

  CardDetail.fromJson(Map<String, dynamic> json) {
    brand = json['brand'];
    country = json['country'];
    expMonth = json['exp_month'];
    expYear = json['exp_year'];
    fingerprint = json['fingerprint'];
    funding = json['funding'];
    last4 = json['last4'];
    networks = json['networks'] != null
        ?  Networks.fromJson(json['networks'])
        : null;
    wallet = json['wallet'] != null
        ?  Wallet.fromJson(json['wallet'])
        : null;
    threeDSecureUsage = json['three_d_secure_usage'] != null
        ?  ThreeDSecureUsage.fromJson(json['three_d_secure_usage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['brand'] = brand;
    data['country'] = country;
    data['exp_month'] = expMonth;
    data['exp_year'] = expYear;
    data['fingerprint'] = fingerprint;
    data['funding'] = funding;
    data['last4'] = last4;
    if (networks != null) {
      data['networks'] = networks!.toJson();
    }
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (threeDSecureUsage != null) {
      data['three_d_secure_usage'] = threeDSecureUsage!.toJson();
    }
    return data;
  }
}

class Networks {
  List<String>? available;

  Networks({this.available,
  });

  Networks.fromJson(Map<String, dynamic> json) {
    available = json['available'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['available'] = available;
    return data;
  }
}

class ThreeDSecureUsage {
  bool? supported;

  ThreeDSecureUsage({this.supported});

  ThreeDSecureUsage.fromJson(Map<String, dynamic> json) {
    supported = json['supported'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['supported'] = supported;
    return data;
  }
}
class Wallet {
  String? type;

  Wallet({this.type});

  Wallet.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    return data;
  }
}

class BillingDetails {
  Address? address;
  String? email;
  String? name;
  String? phone;

  BillingDetails({this.address, this.email, this.name, this.phone});

  BillingDetails.fromJson(Map<String, dynamic> json) {
    address =
    json['address'] != null ?  Address.fromJson(json['address']) : null;
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingDetails &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          email == other.email &&
          name == other.name &&
          phone == other.phone;

  @override
  int get hashCode =>
      address.hashCode ^ email.hashCode ^ name.hashCode ^ phone.hashCode;
}

class Address {
  String? city;
  String? country;
  String? line1;
  String? line2;
  String? postalCode;
  String? state;

  Address(
      {this.city,
        this.country,
        this.line1,
        this.line2,
        this.postalCode,
        this.state});

  Address.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    line1 = json['line1'];
    line2 = json['line2'];
    postalCode = json['postal_code'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['country'] = country;
    data['line1'] = line1;
    data['line2'] = line2;
    data['postal_code'] = postalCode;
    data['state'] = state;
    return data;
  }
}