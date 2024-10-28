import 'dart:io';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreference {
  // ignore: constant_identifier_names
  static const THEME_STATUS = "THEMESTATUS";
  // ignore: constant_identifier_names
  static const LOCALE = "LOCALE";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  setLocale(Locale value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(LOCALE, value.toString());
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pLocale = Platform.localeName.split("_")[0];
    pLocale = pLocale != "it" && pLocale != "en" ? "en" : pLocale;

    return prefs.getString(LOCALE) != null ? Locale(prefs.getString(LOCALE)!) : Locale(pLocale);
  }
}
