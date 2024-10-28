import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import '../tac_logo.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  UserHeaderState createState() => UserHeaderState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class UserHeaderState extends State<UserHeader> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  UserHeader get widget => super.widget;

  String? getProfileImage(Box box) {
    var us = User.fromJson(jsonDecode(box.get('user')));
    return us.profileImage;
  }

  @override
  Widget build(BuildContext context) {
    var isPremium =
        (user.subscriptionType != null && user.subscriptionType == 2) ||
            user.isCompanyPremium;

    if (!isPremium) {
      return Stack(
        children: [
          Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(30)),
              child: getProfileImage(widget.box) == null ||
                  getProfileImage(widget.box)!.isEmpty
                  ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TacLogo(forProfileImage: true),
                    Container(
                        constraints: BoxConstraints.loose(
                            const Size.fromHeight(60.0)),
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
                          ],
                        ))
                  ])
                  : Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image:
                          NetworkImage(getProfileImage(widget.box)!)),
                      borderRadius: BorderRadius.circular(30))))
        ],
      );
    } else {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(30)),
              child: getProfileImage(widget.box) == null ||
                      getProfileImage(widget.box)!.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          const TacLogo(forProfileImage: true),
                          Container(
                              constraints: BoxConstraints.loose(
                                  const Size.fromHeight(60.0)),
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
                                ],
                              ))
                        ])
                  : Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  NetworkImage(getProfileImage(widget.box)!)),
                          borderRadius: BorderRadius.circular(30)))),
          Positioned(
              bottom: -20,
              left: 40,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(
                    Icons.star,
                    size: 20,
                    color: color.computeLuminance() > 0.5
                        ? Theme.of(context).textTheme.bodyText2!.color
                        : Colors.white,
                  ))),
        ],
      );
    }
  }
}
