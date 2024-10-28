import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tac/constants.dart';
import 'package:tac/models/billing.dart';

import '../models/shipping.dart';
import 'auth_service.dart';

Future deleteAddressElement(int id) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/Account/DeleteBillingAddress?id=$id'),
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

Future insertBilling(
    ShippingAddress? shippingAddress, BillingAddress billingAddress) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.put(
        Uri.parse('${Constants.apiUrl}/Account/InsertBillingAddress'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "shippingAddress": shippingAddress?.toJson(),
          "billingAddress": billingAddress.toJson(),
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future updateBilling(
    ShippingAddress? shippingAddress, BillingAddress billingAddress) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Account/UpdateBillingAddress'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "shippingAddress": shippingAddress?.toJson(),
          "billingAddress": billingAddress.toJson(),
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<BillingAddress>> getBilling(int userTacid) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Account/GetBillingAddresses?userId=$userTacid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<BillingAddress>.from(
          l.map((model) => BillingAddress.fromJson(model)));
    } else {
      return List.empty();
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}