import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/models/contact_company.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../extentions/hexcolor.dart';

class ContactCompanyListItem extends StatefulWidget {
  const ContactCompanyListItem(
      {Key? key,
      required this.item,
      required this.onLongPress,
      this.isLongPressMode = false,
      this.isChecked = false,
      this.onItemCheck,
      required this.onTap,
      this.usePadding = false})
      : super(key: key);
  final ContactCompany item;
  final bool isLongPressMode;
  final bool isChecked;
  final bool usePadding;
  final void Function(bool value)? onItemCheck;
  final void Function() onLongPress;
  final void Function() onTap;

  @override
  ContactCompanyListItemState createState() => ContactCompanyListItemState();
}

class ContactCompanyListItemState extends State<ContactCompanyListItem> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  ContactCompanyListItem get widget => super.widget;
  ContactCompany get item => super.widget.item;

  void onLongPress() {
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: onLongPress,
        onTap: widget.onTap,
        child: Container(
            color: widget.isChecked
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).backgroundColor,
            height: 70,
            padding: widget.usePadding
                ? const EdgeInsets.fromLTRB(20, 5, 20, 5)
                : null,
            child: Column(children: [
              Row(children: [
                item.image == null || item.image!.isEmpty
                    ? Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: color,
                        ),
                      )
                    : Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(item.image.toString())),
                            borderRadius: BorderRadius.circular(20))),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 15, 0)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    item.companyName,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color),
                  ),
                  Row(children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: Theme.of(context).textTheme.headline2!.color,
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                    Text(
                      "${item.contactCount} ${AppLocalizations.of(context)!.contacts}",
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.headline2!.color),
                    )
                  ])
                ]),
                const Spacer(),
                // if (!widget.isLongPressMode)
                //   GestureDetector(
                //       child: Icon(Icons.more_horiz,
                //           color: Theme.of(context).textTheme.headline1!.color,
                //           size: 45)),
                if (widget.isLongPressMode)
                  Transform.scale(
                      scale: 1.4,
                      child: Checkbox(
                        checkColor: color.computeLuminance() > 0.5
                            ? Theme.of(context).textTheme.bodyText2!.color
                            : Colors.white,
                        fillColor: MaterialStateProperty.all(color),
                        value: widget.isChecked,
                        shape: const CircleBorder(),
                        onChanged: (bool? value) =>
                            widget.onItemCheck!(value ?? false),
                      ))
              ])
            ])));
  }
}
