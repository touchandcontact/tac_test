import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../extentions/hexcolor.dart';

class LongGrayButton extends StatefulWidget {
  const LongGrayButton(
      {Key? key,
      required this.onPress,
      required this.icon,
      required this.text,
      this.fontSize,
      this.radius,
      this.padding})
      : super(key: key);
  final void Function() onPress;
  final String text;
  final IconData icon;
  final double? fontSize;
  final double? radius;
  final double? padding;

  @override
  LongGrayButtonState createState() => LongGrayButtonState();
}

class LongGrayButtonState extends State<LongGrayButton> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  LongGrayButton get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.onPress,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        widget.radius == null ? 10 : widget.radius!))),
            padding: MaterialStateProperty.all(
                EdgeInsets.all(widget.padding == null ? 18 : widget.padding!)),
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).secondaryHeaderColor)),
        child: Row(
          children: [
            Icon(widget.icon,
                size: 25, color: Theme.of(context).textTheme.headline1!.color),
            const Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
            Text(widget.text,
                style: GoogleFonts.montserrat(
                    fontSize: widget.fontSize == null ? 18 : widget.fontSize!,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headline1!.color)),
            const Spacer(),
            Icon(Icons.chevron_right,
                size: 35, color: Theme.of(context).textTheme.headline1!.color)
          ],
        ));
  }
}
