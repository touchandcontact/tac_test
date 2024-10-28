import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../extentions/hexcolor.dart';

class TacLogo extends StatefulWidget {
  const TacLogo(
      {Key? key,
      required this.forProfileImage,
      this.centered = false,
      this.color})
      : super(key: key);
  final bool forProfileImage;
  final Color? color;
  final bool centered;

  @override
  TacLogoState createState() => TacLogoState();
}

class TacLogoState extends State<TacLogo> {
  @override
  TacLogo get widget => super.widget;

  Color color = Colors.green;

  @override
  void initState() {
    color = widget.color ??
        HexColor.fromHex(Hive.box("settings").get("color").toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.forProfileImage
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.rotate(
                  angle: 24.2,
                  child: Container(
                    width: 8,
                    height: 15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  )),
              const Padding(padding: EdgeInsets.fromLTRB(6, 0, 6, 0)),
              Transform.translate(
                  offset: const Offset(0, -7),
                  child: Container(
                    width: 8,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  )),
              const Padding(padding: EdgeInsets.fromLTRB(6, 0, 6, 0)),
              Transform.rotate(
                  angle: -24.2,
                  child: Container(
                    width: 8,
                    height: 15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  ))
            ]))
        : Row(
            mainAxisAlignment: widget.centered
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Transform.rotate(
                  angle: 24.5,
                  child: Container(
                    width: 9,
                    height: 16,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  )),
              const Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
              Transform.translate(
                  offset: const Offset(0, -7),
                  child: Container(
                    width: 9,
                    height: 26,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  )),
              const Padding(padding: EdgeInsets.fromLTRB(4, 0, 4, 0)),
              Transform.rotate(
                  angle: -24.5,
                  child: Container(
                    width: 9,
                    height: 16,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), color: color),
                  ))
            ],
          );
  }
}
