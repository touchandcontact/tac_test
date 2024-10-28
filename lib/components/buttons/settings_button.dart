import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tac/themes/theme_data.dart';
import '../../extentions/hexcolor.dart';

class SettingsButton extends StatefulWidget {
  const SettingsButton({Key? key,
    required this.onPress,
    required this.text,
    required this.consumer,
    this.icon,
    this.subText,
    this.fontSize,
    this.radius,
    this.padding,
    this.colorIcon,
    this.colorText,
  })
      : super(key: key);
  final void Function() onPress;
  final bool consumer;
  final String text;
  final IconData? icon;
  final String? subText;
  final double? fontSize;
  final double? radius;
  final double? padding;
  final Color? colorIcon;
  final Color? colorText;

  @override
  SettingsButtonState createState() => SettingsButtonState();
}

class SettingsButtonState extends State<SettingsButton> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  SettingsButton get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return
      !widget.consumer ?
      TextButton(
          onPressed: widget.onPress,
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          widget.radius == null ? 10 : widget.radius!))),
              padding: MaterialStateProperty.all(
                  EdgeInsets.all(
                      widget.padding == null ? 10 : widget.padding!)),
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme
                      .of(context)
                      .secondaryHeaderColor)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.subText != null ?
              Row(
                children: [
                  const Padding(padding: EdgeInsets.fromLTRB(2, 0, 0, 0)),
                  Text(widget.subText!,
                      style: GoogleFonts.montserrat(
                          fontSize: widget.fontSize == null ? 13 : widget
                              .fontSize!,
                          fontWeight: FontWeight.w600,
                          color: Theme
                              .of(context)
                              .textTheme
                              .headline2!
                              .color)),
                ],
              ) : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.fromLTRB(2, 0, 0, 0)),
                  SizedBox(width: 240, child: Text(widget.text,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                          fontSize: widget.fontSize == null ? 18 : widget
                              .fontSize!,
                          fontWeight: FontWeight.w600,
                          color: widget.colorText ??  Theme
                              .of(context)
                              .textTheme
                              .headline1!
                              .color))),
                  const Spacer(),
                  Icon(widget.icon ?? Icons.chevron_right,
                      size: 35, color: widget.colorIcon ?? Theme
                          .of(context)
                          .textTheme
                          .headline1!
                          .color)
                ],
              ),
            ],
          )) :
      Stack(
        children: [
          TextButton(
              onPressed: widget.onPress,
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              widget.radius == null ? 10 : widget.radius!))),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.all(
                          widget.padding == null ? 10 : widget.padding!)),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme
                          .of(context)
                          .secondaryHeaderColor)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.subText != null ?
                  Row(
                    children: [
                      const Padding(padding: EdgeInsets.fromLTRB(2, 0, 0, 0)),
                      Text(widget.subText!,
                          style: GoogleFonts.montserrat(
                              fontSize: widget.fontSize == null ? 13 : widget
                                  .fontSize!,
                              fontWeight: FontWeight.w600,
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .headline2!
                                  .color)),
                    ],
                  ) : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.fromLTRB(2, 0, 0, 0)),
                        Text(widget.text,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                                fontSize: widget.fontSize == null ? 18 : widget
                                    .fontSize!,
                                fontWeight: FontWeight.w600,
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .headline1!
                                    .color)),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              )),
          Consumer<ThemeNotifier>(
            builder: (context, value, child) =>
                SwitchListTile(
                    value: value.isDarkTheme,
                    onChanged: (val) {
                      value.toggleTheme();
                    }),
          ),
        ],
      );
  }
}