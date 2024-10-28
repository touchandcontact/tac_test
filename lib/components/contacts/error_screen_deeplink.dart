import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../extentions/hexcolor.dart';

class ErrorScreenDeepLink extends StatefulWidget {

  const ErrorScreenDeepLink({Key? key})
      : super(key: key);

  @override
  State<ErrorScreenDeepLink> createState() => _ErrorScreenDeepLinkState();
}

class _ErrorScreenDeepLinkState extends State<ErrorScreenDeepLink> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          _errorWidget(),
          const Spacer(),
        ],
      )),
    );
  }


  _generateTextWidget(String value, Color color,
      {double fontSize = 16,
        FontWeight fontWeight = FontWeight.w500,
        TextAlign? textAlign}) =>
      Text(
        value,
        textAlign: textAlign,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _errorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 120, color: Colors.red),
          const SizedBox(
            height: 40,
          ),
          _generateTextWidget(
              AppLocalizations.of(context)!.scanError, Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600, fontSize: 22),
          const SizedBox(
            height: 20,
          ),
          _generateTextWidget(
              AppLocalizations.of(context)!.nfcErrorSameIdentifier,
              Theme.of(context).textTheme.headline2!.color!,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
