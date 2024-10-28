import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/ocr_contact_dto.dart';
import '../constants.dart';
import 'auth_service.dart';

Future<OcrContactDto> getOcrData(int idUser, String businessCardImage) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse(
            '${Constants.apiUrl}/OCR/GetOCRData'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "idUser": idUser,
          "businessCardImage": businessCardImage,
        }));

    if (response.statusCode == 200) {
      return OcrContactDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}