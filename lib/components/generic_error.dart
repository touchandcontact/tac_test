import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../extentions/hexcolor.dart';

class GenericError extends StatefulWidget {
  const GenericError({Key? key, required this.onPress}) : super(key: key);
  final Future Function() onPress;

  @override
  State<GenericError> createState() => GenericErrorState();
}

class GenericErrorState extends State<GenericError> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  GenericError get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 120,
                    ),
                    Text(
                      "${AppLocalizations.of(context)!.ops}!",
                      style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.headline1!.color),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      AppLocalizations.of(context)!.somethingWrong,
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.headline2!.color),
                    )
                  ]),
              const Spacer(),
              Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: LoadingButton(
                      onPress: widget.onPress,
                      text: AppLocalizations.of(context)!.tryAgain,
                      color: color,
                      borderColor: color,
                      width: 150))
            ]));
  }
}
