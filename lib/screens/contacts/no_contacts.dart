import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../extentions/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoContacts extends StatefulWidget {
  const NoContacts(
      {super.key, required this.onButtonPress, this.isCompany = false});
  final Function() onButtonPress;
  final bool isCompany;

  @override
  NoContactsState createState() => NoContactsState();
}

class NoContactsState extends State<NoContacts> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  @override
  NoContacts get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Image.asset("assets/images/nodata.png",
            width: MediaQuery.of(context).size.width * 0.8),
        const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
        Text(AppLocalizations.of(context)!.noOneHere,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline1),
        if (!widget.isCompany)
          Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 40, 30),
              child: Text(
                  AppLocalizations.of(context)!.emptyContactList,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).textTheme.headline2!.color,
                      fontSize: 16))),
        if (!widget.isCompany)
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: OutlinedButton(
                  onPressed: widget.onButtonPress,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(width: 1.0, color: color),
                      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(15),
                              right: Radius.circular(15)))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: color, size: 30),
                        Text(
                          AppLocalizations.of(context)!.addPeople,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: color,
                              fontWeight: FontWeight.w600),
                        )
                      ])))
      ]),
    );
  }
}
