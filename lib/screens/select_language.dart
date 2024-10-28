import 'dart:convert';

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tac/services/account_service.dart';
import '../components/buttons/loading_button.dart';
import '../constants.dart';
import '../extentions/hexcolor.dart';
import '../models/user.dart';
import '../themes/dark_theme_provider.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  List<bool> _isChecked =
      List<bool>.filled(Constants.languageSelected.values.length, false);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() {
      DarkThemeProvider themeChangeProvider = Provider.of<DarkThemeProvider>(context, listen: false);
      setChecked(themeChangeProvider.locale);
    });
  }

  void setChecked(Locale l){
    var language = l.toString() == "en" ? "gb-eng" : l.toString();
    var selected = Constants.languageSelected.values.toList().indexOf(language);

    setState(() {
      _isChecked[selected] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    DarkThemeProvider themeChangeProvider = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(8.8, 0, 0, 0),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ),
        body: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
            child: RichText(
                overflow: TextOverflow.clip,
                text: TextSpan(
                  text: AppLocalizations.of(context)!.selectLanguageApp,
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headline2!.color),
                )),
          ),
          ListView.separated(
              shrinkWrap: true,
              itemCount: Constants.languageSelected.values.length,
              itemBuilder: (context, index) =>
                  _select(Constants.languageSelected[index], index),
              separatorBuilder: (context, index) => Divider(
                  height: 5,
                  color: Theme.of(context).textTheme.headline2!.color)),
          const Spacer(), // I just added one line
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingButton(
                    onPress: () => select(themeChangeProvider),
                    width: 145,
                    text: AppLocalizations.of(context)!.confirmation,
                    color: color,
                    borderColor: color)
              ],
            ),
          )
        ]));
  }

  Future select(DarkThemeProvider provider) async {
    var language = Constants.languageSelected[_isChecked.indexWhere((element) => element==true)];
    var correctLanguage = language == "gb-eng" ? "en" : language;
    provider.locale = Locale(correctLanguage);

    try{
      await setLanguage(user.tacUserId, correctLanguage);
    }
    catch(_){}

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    return Future.value();
  }

  _select(value, index) {
    return Stack(children: [
      GestureDetector(
        onTap: () {
          _isChecked = List<bool>.filled(
              Constants.languageSelected.values.length, false);
          _isChecked[index] = !_isChecked[index];
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.only(left: 5, right: 15),
          alignment: Alignment.center,
          height: 70,
          decoration: BoxDecoration(
            color: _isChecked[index]
                ? Theme.of(context).secondaryHeaderColor
                : Colors.white,
          ),
          child: ListTile(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChecked = List<bool>.filled(
                          Constants.languageSelected.values.length, false);
                      _isChecked[index] = !_isChecked[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: _isChecked[index]
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _isChecked[index]
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color!,
                                width: 1)),
                        child: Icon(Icons.check,
                            color: _isChecked[index]
                                ? Theme.of(context).backgroundColor
                                : Colors.white)),
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleFlag(value, size: 40),
                ),
                RichText(
                    overflow: TextOverflow.clip,
                    text: TextSpan(
                      text: _textLanguage(value),
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headline1!.color),
                    )),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  String _textLanguage(value) {
    String label = "";
    switch (value) {
      case "it":
        label = AppLocalizations.of(context)!.it;
        break;
      case "gb-eng":
        label = AppLocalizations.of(context)!.en;
        break;
      case "fr":
        label = AppLocalizations.of(context)!.fr;
        break;
      case "es":
        label = AppLocalizations.of(context)!.es;
        break;
      case "de":
        label = AppLocalizations.of(context)!.de;
        break;
      default:
        label = "";
    }
    return label;
  }
}
