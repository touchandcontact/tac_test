import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/billing.dart';

import '../constants.dart';
import '../helpers/toast_helper.dart';
import '../models/card_model.dart';
import '../models/payment_list_card.dart';
import '../models/stripe_complete_subscription_for_mobile_dto.dart';
import '../models/stripe_price_dto.dart';
import '../models/stripe_product_dto.dart';
import '../models/subscribe.dart';
import '../models/subscription.dart';
import 'auth_service.dart';

Future<List<StripeProductDto>> getProductByName(String text) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Stripe/GetProductByName?name=$text'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      List<StripeProductDto> products = List<StripeProductDto>.from(l.map((model)=> StripeProductDto.fromJson(model)));
      return products;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<StripePriceDto>> getProductPrices(String text) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Stripe/GetProductPrices?productId=$text'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      List<StripePriceDto> prices = List<StripePriceDto>.from(l.map((model)=> StripePriceDto.fromJson(model)));
      return prices;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<PaymentListCard>> getListCard(String striepeId,{bool hideAppleGooglePay = false}) async {
  try {
    var response = await http.get(
        Uri.parse(
            'https://api.stripe.com/v1/payment_methods?customer=$striepeId&type=card'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${Constants.stripePrivateKey}'
        });
    if (response.statusCode == 200) {
      // print(jsonDecode(response.body)["data"]);
      Iterable l = jsonDecode(response.body)["data"];
      List<PaymentListCard> listCard = List<PaymentListCard>.from(
          l.map((model) => PaymentListCard.fromJson(model)));
      if(hideAppleGooglePay){
        listCard.removeWhere((element) => element.card?.wallet?.type=="google_pay" || element.card?.wallet?.type=="apple_pay");
      }
      return listCard;
    } else {
      return List.empty();
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

///inserimento dell'account su stripe
Future insertStripeAccount(int userId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.put(
        Uri.parse('${Constants.apiUrl}/Account/CreateStripeCustomer'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    if (response.statusCode != 200) {
      showErrorToast("Si é verificato un errore");
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

///inserimento carta collegata account stripe (stripeid/customerid)
Future insertStripeCard(CardModel? paymentCard, String customer) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Stripe/CreateCustomerPaymenthMethod'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'customerId': customer,
          'cardModel': paymentCard?.toJson(),
        }));
    if (response.statusCode != 200) {
      showErrorToast("Si é verificato un errore");
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future attachPaymentMethod(String id, String customer) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Stripe/AttachPaymentMethod'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'customerId': customer,
          'id': id,
        }));
    if (response.statusCode != 200) {
      showErrorToast("Si é verificato un errore");
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<Subscription> saveSubscription(Subscribe? subscribe, BillingAddress? billingAddress) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Stripe/SaveSubscription'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'Price': subscribe?.price.toString(),
          'Coupon': subscribe?.coupon.toString(),
          'Currency': subscribe?.currency.toString(),
          'Customer': subscribe?.customer.toString(),
          'Quantity': subscribe?.quantity,
          'PaymentMethd': subscribe?.paymentMethd.toString(),
          'IsIos': Platform.isIOS,
          'BillingAddress': billingAddress,
          'AppleTransactionId': subscribe?.transactionId
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }else{
      Subscription model = Subscription.fromJson(jsonDecode(response.body));

      if(model.intentStatus == "succeeded") showSuccessToast(model.intentStatus ?? "");
      return model;
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

///disabilitito per mancata possibilita di aggiornare la carta su stripe
Future updateStripeCard(CardModel? paymentCard) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Stripe/EditCustomerPaymenthMethod'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(paymentCard?.toJson()));
    // print(paymentCard?.toJson());
    if (response.statusCode != 200) {
      showErrorToast("Si é verificato un errore");
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

///aggiornamento/cambio sottoscrizione e tipo
Future updateSubscription(int? userId, int subscriptionType) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Account/UpdateSubscription'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'subscriptionType': subscriptionType,
        }));
    if (response.statusCode != 200) {
      showErrorToast("Si é verificato un errore");
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

///eliminazione carta da stripe
Future deleteCardElement(String id) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse(
            '${Constants.apiUrl}/Stripe/DetachCustomerPaymenthMethod?id=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<StripeCompleteSubscriptionForMobileDto> getCurrentSubscription(int tacuserid) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Stripe/GetCurrentSubscription?id=$tacuserid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return StripeCompleteSubscriptionForMobileDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future cancelSubscription(int tacuserid) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse(
            '${Constants.apiUrl}/Stripe/CancelSubscription?id=$tacuserid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<bool> updatePaymentCard(int userId, String paymentId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Stripe/UpdatePaymentCard'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          "paymentId": paymentId
        }));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}
