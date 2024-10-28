import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tac/extentions/hexcolor.dart';
import 'package:tac/helpers/material_color_helper.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
        primarySwatch: createMaterialColor(HexColor.fromHex("01b0b3")),
        primaryColor: isDarkTheme ? Colors.black : HexColor.fromHex("01b0b3"),
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        textTheme: TextTheme(
            headline1: GoogleFonts.montserrat(
                color: isDarkTheme ? Colors.white : HexColor.fromHex("00041F"),
                fontSize: 20,
                fontWeight: FontWeight.bold),
            headline2: GoogleFonts.montserrat(
                color: isDarkTheme ? Colors.white : HexColor.fromHex("8B98B2"),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            headline3: GoogleFonts.montserrat(
                color: isDarkTheme ? Colors.white : HexColor.fromHex("00041F"),
                fontSize: 14,
                fontWeight: FontWeight.w500),
            bodyText1: GoogleFonts.montserrat(
                color: isDarkTheme ? Colors.white : HexColor.fromHex("8B98B2")),
            bodyText2: GoogleFonts.montserrat(
                color:
                    isDarkTheme ? Colors.white : HexColor.fromHex("00041F"))),
        disabledColor: Colors.grey,
        secondaryHeaderColor: HexColor.fromHex("F4F6FB"),
        dividerColor: HexColor.fromHex("E9EEF8"),

        bottomSheetTheme:
            const BottomSheetThemeData(backgroundColor: Colors.transparent),
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
            colorScheme: isDarkTheme
                ? const ColorScheme.dark()
                : const ColorScheme.light()),
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
        ));
  }
}
class ThemeNotifier extends ChangeNotifier {
    String key = "theme";
   late  SharedPreferences prefs;
   bool isDarkTheme = false;

   ThemeNotifier() {
     isDarkTheme = true;
   }
   toggleTheme()  {
     isDarkTheme = !isDarkTheme;
     notifyListeners();
   }

}