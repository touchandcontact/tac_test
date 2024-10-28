import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../extentions/hexcolor.dart';
import '../../models/contact.dart';

class SharedAvatar extends StatefulWidget {
  const SharedAvatar({Key? key, required this.item}) : super(key: key);
  final Contact item;

  @override
  SharedAvatarState createState() => SharedAvatarState();
}

class SharedAvatarState extends State<SharedAvatar> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  SharedAvatar get widget => super.widget;
  Contact get item => super.widget.item;

  @override
  Widget build(BuildContext context) {
    if (item.profileImage == null || item.profileImage!.isEmpty) {
      return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Center(
              child: Text(
            item.name[0],
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
                color: color, fontSize: 20, fontWeight: FontWeight.w600),
          )));
    } else {
      return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              image: DecorationImage(
                  image: NetworkImage(item.profileImage!), fit: BoxFit.cover)));
    }
  }
}
