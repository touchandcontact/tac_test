import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/user_documents_or_links.dart';
import 'package:tac/models/user_green_insight_model.dart';
import '../constants.dart';
import '../models/user_insight_counters_model.dart';
import 'auth_service.dart';

Future<int> getCountOcr(int tacUserId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Statistics/GetCountOcr?tacUserId=$tacUserId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<UserDocumentsOrLinks>> getUserDocumentsDowloadClicked(
    int tacUserId, int timeLenghtType) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Statistics/GetUserDocumentsDowloadClicked?tacUserId=$tacUserId&timeLenghtType=$timeLenghtType'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<UserDocumentsOrLinks>.from(
          l.map((model) => UserDocumentsOrLinks.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<UserInsightCountersModel> getUserInsight(int tacUserId, int timeLenghtType) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Statistics/GetUserInsight?tacUserId=$tacUserId&timeLenghtType=$timeLenghtType'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return UserInsightCountersModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<UserGreenInsightModel> getUserGreenInsight(int tacUserId, int timeLenghtType) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Statistics/GetUserGreenInsight?tacUserId=$tacUserId&timeLenghtType=$timeLenghtType'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return UserGreenInsightModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future addInsightUserProfileView(
    int userId, int viewingUserId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Statistics/AddInsightUserProfileView'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          "viewingUserId": viewingUserId,
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

Future<bool> adddInsightUserDocDowloadCount(
    int userId, int viewingUserId, int documentId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Statistics/AddInsightUserDocDowloadCount'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          "viewingUserId": viewingUserId,
          "documentId": documentId,
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

Future<bool> addInsightUserCount(
    String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Statistics/AddInsightUserCount'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "stringValue": identifier,
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

Future<bool> addInsightProfileDownload(
    int userId, int downloaderId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Statistics/AddInsightProfileDownload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          "downloaderId": downloaderId,
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