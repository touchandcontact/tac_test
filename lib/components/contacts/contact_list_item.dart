import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tac/models/contact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../extentions/hexcolor.dart';

class ContactListItem extends StatefulWidget {
  const ContactListItem(
      {Key? key,
      required this.item,
      required this.onLongPress,
      this.isLongPressMode = false,
      this.isChecked = false,
      this.onItemCheck,
      required this.onTap,
      this.useBackgroundColor = true,
      this.hideMenu = false,
        required this.iconFunction,
        this.usePadding = false})
      : super(key: key);
  final Contact item;
  final bool isLongPressMode;
  final bool isChecked;
  final bool usePadding;
  final bool useBackgroundColor;
  final bool hideMenu;
  final void Function(bool value)? onItemCheck;
  final void Function() onLongPress;
  final void Function() onTap;
  final void Function() iconFunction;

  @override
  ContactListItemState createState() => ContactListItemState();
}

class ContactListItemState extends State<ContactListItem> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  ContactListItem get widget => super.widget;
  Contact get item => super.widget.item;

  void onLongPress() {
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: onLongPress,
        onTap: widget.onTap,
        child: Container(
            color: widget.isChecked && widget.useBackgroundColor
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).backgroundColor,
            height: 70,
            padding: widget.usePadding
                ? const EdgeInsets.fromLTRB(20, 5, 20, 5)
                : null,
            child: Column(children: [
              Row(children: [
                item.profileImage == null || item.profileImage!.isEmpty
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
                                image:
                                    NetworkImage(item.profileImage.toString())),
                            borderRadius: BorderRadius.circular(20))),
                const Padding(padding: EdgeInsets.fromLTRB(0, 0, 8, 0)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    item.name,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color),
                  ),
                  if (item.profession != null)
                    SizedBox(width: MediaQuery.of(context).size.width * .57, child: Text(
                      item.profession.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.headline2!.color),
                    )),
                  Text(
                    "${AppLocalizations.of(context)!.addContactDate} ${DateFormat("dd - MM - yyyy").format(item.creationDate ?? DateTime.now())}",
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline3!.color),
                  )
                ]),
                const Spacer(),
                if (!widget.isLongPressMode && !widget.hideMenu)
                  GestureDetector(
                      child: Icon(Icons.more_horiz,
                          color: Theme.of(context).textTheme.headline1!.color,
                          size: 45),
                    onTap: () {
                        widget.iconFunction();
                    },
                  ),
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
