import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tac/models/folder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../extentions/hexcolor.dart';

class FolderListItem extends StatefulWidget {
  const FolderListItem({Key? key, required this.item, required this.onTap})
      : super(key: key);
  final Folder item;
  final void Function() onTap;

  @override
  FolderListItemState createState() => FolderListItemState();
}

class FolderListItemState extends State<FolderListItem> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  Folder get item => super.widget.item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            height: 80,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                const Icon(Icons.people_alt_outlined, size: 40),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 15, 0)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * .59,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              item.name.toLowerCase() == "preferiti" ? AppLocalizations.of(context)!.favorites : item.name,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color),
                            ),
                            if (item.addHubspot || item.addSalesForce)
                            const SizedBox(width: 10),
                            if (item.addHubspot)
                              Image.asset("assets/images/HubSpot.png",
                                  width: 20),
                            if (item.addHubspot && item.addSalesForce)
                              const SizedBox(width: 5),
                            if (item.addSalesForce)
                              Image.asset("assets/images/salesforce.png",
                                  width: 20)
                          ])),
                  Text(
                    "${AppLocalizations.of(context)!.created}: ${DateFormat("dd/MM/yyyy").format(item.creationDate ?? DateTime.now())}",
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
                  if (item.name.toLowerCase() != "preferiti")
                    Row(children: [
                      Icon(Icons.people,
                          size: 20,
                          color: Theme.of(context).textTheme.headline2!.color),
                      const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                      Text(
                        "${item.countContact} ${AppLocalizations.of(context)!.contacts}",
                        style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.headline2!.color),
                      )
                    ])
                  else
                    Container(
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color:
                                Theme.of(context).textTheme.headline2!.color),
                        child: Text(AppLocalizations.of(context)!.favorites,
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)))
                ]),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context).textTheme.headline1!.color,
                    size: 30)
              ])
            ])));
  }
}
