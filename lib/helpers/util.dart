import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../enums/type_action.dart';
import '../services/account_service.dart';
import '../services/statistics_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class Util {
  static double remap(
      double value,
      double originalMinValue,
      double originalMaxValue,
      double translatedMinValue,
      double translatedMaxValue) {
    if (originalMaxValue - originalMinValue == 0) return 0;

    return (value - originalMinValue) /
            (originalMaxValue - originalMinValue) *
            (translatedMaxValue - translatedMinValue) +
        translatedMinValue;
  }

  static openLink(String value, TypeAction typeAction, context) async {
    try{
      if(typeAction == TypeAction.LINK_WEB){
        launchUrl(Uri.parse(value));
      }else if(typeAction == TypeAction.TELEFONO){
        final Uri telephone = Uri(
          scheme: 'tel',
          path: value,
        );
        await launchUrl(telephone);
      }else if(typeAction == TypeAction.EMAIL){
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: value,
        );
        await launchUrl(emailLaunchUri);
      }else{
        String mapUrl = "";
        if(Platform.isAndroid){
          String query = Uri.encodeComponent(value);
          mapUrl = "https://www.google.com/maps/search/?api=1&query=$query";
        }else{
          String query = Uri.encodeComponent(value);
          mapUrl = 'http://maps.apple.com/?q=$query';
        }
        launchUrl(Uri.parse(mapUrl),mode: LaunchMode.externalApplication);
      }
    }catch(e){
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  static returnCorrectLabel(TypeAction typeAction,context){
    switch(typeAction){
      case TypeAction.INDIRIZZO:
        return AppLocalizations.of(context)!.address;
      case TypeAction.LINK_WEB:
        return AppLocalizations.of(context)!.website;
      case TypeAction.EMAIL:
        return AppLocalizations.of(context)!.email;
      case TypeAction.TELEFONO:
        return AppLocalizations.of(context)!.telephone;
    }
  }

  static Future<void> saveInsights(int tacUserContact, int tacUserLoggato) async {
    try {
      await addInsightUserProfileView(tacUserContact,tacUserLoggato);
    } catch (_) {
      debugPrint("errore salvataggio insight");
    }
  }


  static translatePeriodPayment(String value, context){
    if(value.toLowerCase() == "month"){
      return AppLocalizations.of(context)!.month.toLowerCase();
    }else{
      return AppLocalizations.of(context)!.year.toLowerCase();
    }
  }


  static updateUserInHive(String identifier) async {
    try{
      final newUser = await getUserForEdit(identifier);
      await Hive.box("settings")
          .put("user", jsonEncode(newUser.userDTO.toJson()));
    }catch(e){
      print(e);
    }
  }

    static Future<Uint8List> downloadImage(String imageUrl) async {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image');
      }
    }

    static double transformBytesInMb(int size){
        return size / (1024 * 1024);
    }


    static String? validatorPassword(context, String? pass) {
    String error = "";
      if (pass == null || pass.length < 6) {
        error += "${AppLocalizations.of(context)!.shortPassword}\n";
      }
      if (!pass!.contains(RegExp(r'[A-Z]'))) {
        error += "${AppLocalizations.of(context)!.upperLetterPassword}\n";
      }

      if (!pass.contains(RegExp(r'[a-z]'))) {
        error += "${AppLocalizations.of(context)!.lowerLetterPassword}\n";
      }

      if (!pass.contains(RegExp(r'[0-9]'))) {
        error += "${AppLocalizations.of(context)!.numberPassword}\n";
      }

      if (!pass.contains(RegExp(r'^(?=.*?[!@#\$&*~])'))) {
        error += "${AppLocalizations.of(context)!.specialCharacterPassword}\n";
      }

      if (pass.contains(RegExp(r'(.)\1{1,}'))) {
        error += "${AppLocalizations.of(context)!.doubleSpecialCharacterPassword}\n";
      }
      if(error != "") return error;
      return null;
    }

    static String capitalizeWords(String input) {
      List<String> words = input.split(' ');
      List<String> capitalizedWords = [];

      for (String word in words) {
        if (word.isNotEmpty) {
          capitalizedWords.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
        }
      }

      return capitalizedWords.join(' ');
    }
}
