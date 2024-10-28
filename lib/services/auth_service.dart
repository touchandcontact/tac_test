import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:tac/constants.dart';
import 'package:tac/models/user.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<User, String>> signIn(
    String email, String password, bool rememberMe) async {
  try {
    var response = await http.put(
      Uri.parse('${Constants.apiUrl}/Account/Login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
        'rememberMe': rememberMe
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> userMap = jsonDecode(response.body);
      return Tuple2<User, String>(
          User.fromJson(userMap["item1"]), userMap["item2"]);
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future signUp(String email, String password) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/Registration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'confirmPassword': password
      }),
    );

    if (response.statusCode != 200) throw Exception(response.body);
  } catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future resetPassword(String email) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/ResetPassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<bool> checkCode(String email, String code) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/CheckCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(response.body);
    }
  } catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future updatePassword(String email, String password) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/UpdatePassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<String> refreshToken(String token) async {
  var response = await http.put(
    Uri.parse('${Constants.apiUrl}/Account/RefreshToken'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'token': token}),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception(response.body);
  }
}

Future<String> getAndEventuallyRefreshToken() async {
  var token = Hive.box("settings").get("token");
  Map<String, dynamic> payload = Jwt.parseJwt(token);

  var exp = (payload["exp"] as int) * 1000;
  if (exp <= DateTime.now().millisecondsSinceEpoch) {
    token = await refreshToken(token);
    Hive.box("settings").put("token", token);
  }

  return token;
}

Future<Tuple2<User, String>> externalLogin(String email) async {
  try {
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Account/ExternalLogin?email=$email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> userMap = jsonDecode(response.body);
      return Tuple2<User, String>(
          User.fromJson(userMap["item1"]), userMap["item2"]);
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}
