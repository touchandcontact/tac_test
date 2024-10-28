import 'dart:io';

import 'package:flutter/material.dart';

class SafeAreaCustom extends StatelessWidget {
  Widget child;
  bool isHome;
  SafeAreaCustom({Key? key,required this.child, this.isHome = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: Platform.isIOS ? true : false,
        right: false,
        left: false,
        child:  Platform.isIOS && isHome ? Padding(
            padding: const EdgeInsets.only(top: 25),
            child: child) : child);
  }
}
