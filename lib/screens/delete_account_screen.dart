import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../extentions/hexcolor.dart';
import '../services/account_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'landing.dart';

class DeleteAccountScreen extends StatefulWidget {
  String identifier;

  DeleteAccountScreen({Key? key, required this.identifier}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  bool firstAccept = false;
  bool secondAccept = false;
  bool errorMessage = false;

  Future<void> _deleteUserAccount(context) async {
    try {
      await deleteUserAccount(widget.identifier);
      logOut();
    } catch (e) {
      throw Exception();
    }
  }

  void logOut() async{
    await Hive.deleteFromDisk().then((value) => Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const Landing()),
      ModalRoute.withName('/'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).backgroundColor,
        title: _generateTextWidget(
            AppLocalizations.of(context)!.deleteAccount, Theme.of(context).textTheme.headline1!.color!,
            fontSize: 28, fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.zero,
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                          AppLocalizations.of(context)!.textDeleteAccount,style: TextStyle(fontSize: 20)
                      ),
                      errorMessage ? Column(
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Text(AppLocalizations.of(context)!.acceptPointsControl,style: TextStyle(color: Colors.redAccent,fontSize: 14),)
                        ],
                      ) : const SizedBox(),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Transform.scale(
                              scale: 1.4,
                              child: Checkbox(
                                  checkColor:
                                  color
                                      .computeLuminance() >
                                      0.5
                                      ? Theme.of(
                                      context)
                                      .textTheme
                                      .bodyText2!
                                      .color
                                      : Colors.white,
                                  value: firstAccept,
                                  fillColor:
                                  MaterialStateProperty.all(color),
                                  shape: const CircleBorder(),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      firstAccept =
                                      !firstAccept;
                                    });
                                  }
                                )),
                          Flexible(
                            child: Text(
                                AppLocalizations.of(context)!.removeData,style: TextStyle(fontSize: 16)),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Transform.scale(
                              scale: 1.4,
                              child: Checkbox(
                                  checkColor:
                                  color
                                      .computeLuminance() >
                                      0.5
                                      ? Theme.of(
                                      context)
                                      .textTheme
                                      .bodyText2!
                                      .color
                                      : Colors.white,
                                  value: secondAccept,
                                  fillColor:
                                  MaterialStateProperty.all(color),
                                  shape: const CircleBorder(),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      secondAccept =
                                      !secondAccept;
                                    });
                                  }
                              )),
                          Flexible(
                            child: Text(
                                AppLocalizations.of(context)!.confirmDeleteAccount,style: TextStyle(fontSize: 16),),
                          )
                        ],
                      ),
                      const SizedBox(height: 32,),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: firstAccept && secondAccept ? () async =>
                            await _deleteUserAccount(context) : (){
                              setState(() {
                                errorMessage = true;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(
                                    width: 1.0, color: Colors.redAccent),
                                padding: const EdgeInsets.fromLTRB(
                                    20, 20, 20, 20),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(15),
                                        right: Radius.circular(15)))),
                            child: Text(
                              AppLocalizations.of(context)!.deleteAccountAccept,
                              style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600),
                            )),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 16, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );
}
