import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/models/contact_profile.dart';

import '../../extentions/hexcolor.dart';
import '../tac_logo.dart';

class ContactProfileHeader extends StatefulWidget {
  const ContactProfileHeader(
      {Key? key, required this.contact, required this.onBack})
      : super(key: key);
  final ContactProfile contact;
  final void Function() onBack;

  @override
  ContactProfileHeaderState createState() => ContactProfileHeaderState();
}

class ContactProfileHeaderState extends State<ContactProfileHeader> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  ContactProfileHeader get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    if (widget.contact.coverImage == null) {
      return Column(children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: Icon(Icons.arrow_left,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          color:
                              Theme.of(context).textTheme.bodyText2!.color))),
              Expanded(
                  flex: 6,
                  child: getProfileImageContainer(
                      context, color, widget.contact.profileImage))
            ])),
        const Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            widget.contact.name,
            style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1!.color),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
          Text(widget.contact.surname,
              style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headline1!.color))
        ]),
        if (widget.contact.profession != null)
          const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        if (widget.contact.profession != null)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              widget.contact.profession.toString().toUpperCase(),
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.headline2!.color),
            )
          ])
      ]);
    } else {
      return Container(
          height: 160,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(widget.contact.coverImage.toString()),
                  fit: BoxFit.cover)),
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
                left: 20,
                top: 10,
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: IconButton(
                        splashRadius: 20,
                        onPressed: () {},
                        icon: Icon(Icons.arrow_left,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                        color: Theme.of(context).textTheme.bodyText2!.color))),
            Positioned(
                top: 140,
                left: MediaQuery.of(context).size.width / 2.6,
                child: getProfileImageContainer(
                    context, color, widget.contact.profileImage)),
            const Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                widget.contact.name,
                style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
              Text(widget.contact.surname,
                  style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headline1!.color))
            ]),
            if (widget.contact.profession != null)
              const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            if (widget.contact.profession != null)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  widget.contact.profession.toString().toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headline2!.color),
                )
              ])
          ]));
    }
  }
}

Widget getProfileImageContainer(
    BuildContext context, Color color, String? profileImage) {
  return profileImage == null || profileImage.isEmpty
      ? Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(30)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TacLogo(forProfileImage: true),
                Container(
                    constraints:
                        BoxConstraints.loose(const Size.fromHeight(60.0)),
                    child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Positioned(
                              top: -10,
                              child: Icon(
                                Icons.person,
                                color: color,
                                size: 70,
                              ))
                        ]))
              ]))
      : Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              image: DecorationImage(
                  image: NetworkImage(profileImage), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(30)));
}
