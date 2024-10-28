import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SuggestedLink extends StatefulWidget {
  const SuggestedLink(
      {super.key,
      required this.text,
      required this.icon,
      required this.onAddClick});

  final String text;
  final IconData icon;
  final Function() onAddClick;

  @override
  State<SuggestedLink> createState() => SuggestedLinkState();
}

class SuggestedLinkState extends State<SuggestedLink> {
  @override
  SuggestedLink get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: Theme.of(context).secondaryHeaderColor),
        child: Row(
          children: [
            Icon(widget.icon,
                size: 25, color: Theme.of(context).textTheme.headline1!.color),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Text(widget.text,
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headline1!.color)),
            const Spacer(),
            GestureDetector(
                onTap: widget.onAddClick,
                child: Text(AppLocalizations.of(context)!.add,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color)))
          ],
        ));
  }
}
