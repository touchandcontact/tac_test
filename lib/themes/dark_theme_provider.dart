import 'dart:ui';

import 'package:flutter/cupertino.dart' show ChangeNotifier;
import 'package:tac/themes/shared_preferences.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;
  Locale _locale = const Locale("it");

  bool get darkTheme => _darkTheme;
  Locale get locale => _locale;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  set locale(Locale l){
    _locale = l;
    darkThemePreference.setLocale(l);
    notifyListeners();
  }
}
