import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../extentions/hexcolor.dart';

class TabButton extends StatefulWidget {
  const TabButton(
      {Key? key,
      required this.onPress,
      required this.text,
      required this.active,
      required this.inactiveLeftRadius,
      required this.inactiveRightRadius,
      this.icon,
      this.padding})
      : super(key: key);
  final Future<void>? Function() onPress;
  final String text;
  final bool active;
  final double inactiveLeftRadius;
  final double inactiveRightRadius;
  final IconData? icon;
  final EdgeInsets? padding;

  @override
  TabButtonState createState() => TabButtonState();
}

class TabButtonState extends State<TabButton> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  TabButton get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return TextButton(
          onPressed: widget.onPress,
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(widget.inactiveLeftRadius),
                          right: Radius.circular(widget.inactiveRightRadius)))),
              padding: MaterialStateProperty.all(
                  widget.padding ?? const EdgeInsets.fromLTRB(0, 18, 0, 18)),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).secondaryHeaderColor)),
          child: widget.icon == null
              ? Text(widget.text,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.headline2!.color,
                      fontWeight: FontWeight.w600))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                    Icon(widget.icon,
                        size: 18,
                        color: Theme.of(context).textTheme.headline2!.color),
                    Text(widget.text,
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.headline2!.color,
                            fontWeight: FontWeight.w600)),
                  ],
                ));
    } else {
      return TextButton(
          onPressed: null,
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
              padding: MaterialStateProperty.all(
                  widget.padding ?? const EdgeInsets.fromLTRB(0, 18, 0, 18)),
              backgroundColor: MaterialStateProperty.all(color)),
          child: widget.icon == null
              ? Text(widget.text,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: color.computeLuminance() > 0.5
                          ? Theme.of(context).textTheme.headline1!.color
                          : Colors.white,
                      fontWeight: FontWeight.w600))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                    Icon(widget.icon,
                        size: 18,
                        color: color.computeLuminance() > 0.5
                            ? Theme.of(context).textTheme.headline1!.color
                            : Colors.white),
                    Text(widget.text,
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: color.computeLuminance() > 0.5
                                ? Theme.of(context).textTheme.headline1!.color
                                : Colors.white,
                            fontWeight: FontWeight.w600)),
                  ],
                ));
    }
  }
}
