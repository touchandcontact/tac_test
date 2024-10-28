import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../extentions/hexcolor.dart';

void showLoadingDialog(BuildContext context) {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(50.0)),
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(color: color),
                  )
                ]));
      });
}
