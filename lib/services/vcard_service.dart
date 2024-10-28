import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import 'auth_service.dart';

Future<String> getQRCode(String text, int dimensions) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/GetQrCode?text=$text&dimensions=$dimensions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createVCard(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateVCardWithIdentifier?identifier=$identifier'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createExternalVCard (int contactid) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateExternalVCard?contactid=$contactid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createContactVCard(int id) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateContactVCard?id=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<bool> associateCard(int userId, String link) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse(
            '${Constants.apiUrl}/VCard/AssociateCard'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        }, body: jsonEncode(<String, dynamic>{
      "userId": userId,
      "link": link,
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

Future<String> createGoogleWallet(int cardId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateGoogleWallet?cardId=$cardId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createAppleWallet(int cardId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateAppleWallet?cardId=$cardId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}


Future<String> createVCardStringWithIdentifier(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateVCardStringWithIdentifier?identifier=$identifier'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createGoogleWalletById(int tacuserid) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateGoogleWallet?id=$tacuserid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> createAppleWalletById(int tacuserid) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/VCard/CreateAppleWallet?id=$tacuserid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}