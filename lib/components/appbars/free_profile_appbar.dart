import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:tac/components/user/user_header.dart';
import 'package:tac/screens/preview_screen.dart';

import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../tac_logo.dart';

class FreeProfileAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  const FreeProfileAppbar({super.key, required this.height});
  final double height;

  @override
  FreeProfileAppbarState createState() => FreeProfileAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class FreeProfileAppbarState extends State<FreeProfileAppbar> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  String? companyLogo;

  @override
  FreeProfileAppbar get widget => super.widget;

  @override
  initState() {
    companyLogo = user.isCompanyPremium ? user.company?.logo : null;
    super.initState();
  }

  String? getCoverImage(Box box) {
    var us = User.fromJson(jsonDecode(box.get('user')));
    return us.coverImage;
  }

  String? getProfleImage(Box box) {
    var us = User.fromJson(jsonDecode(box.get('user')));
    return us.profileImage;
  }

  @override
  Widget build(BuildContext context) {
    return HiveListener(
      box: Hive.box('settings'),
      keys: const ['user'],
      builder: (box) {
        return AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            flexibleSpace:
            getCoverImage(box) == null || getCoverImage(box)!.isEmpty
                ? Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 100,
                  child: UserHeader(
                    box: box,
                  ),
                )
              ],
            )
                : Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40),
                  child: Image(
                    image: NetworkImage(getCoverImage(box)!),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                    top: 110,
                    child: UserHeader(
                      box: box,
                    )),
                Positioned(
                  top: 45,
                  right: 20,
                  height: 44,
                  width: 73,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PreviewScreen(identifier: user.identifier))),
                    child: Container(
                        decoration: BoxDecoration(
                            color:Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.preview,
                              style: GoogleFonts.montserrat(
                                  color:Theme.of(context).textTheme.headline1!.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ))
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            title: getCoverImage(box) == null || getCoverImage(box)!.isEmpty ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                ),
                Center(
                  child:
                  getCoverImage(box) == null || getCoverImage(box)!.isEmpty
                      ? const TacLogo(forProfileImage: false)
                      : null,
                ),
                GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PreviewScreen(identifier: user.identifier))),
                    child: Container(
                        height: 44,
                        width: 73,
                        decoration: BoxDecoration(
                            color:Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(AppLocalizations.of(context)!.preview,
                              style: GoogleFonts.montserrat(
                                  color:Theme.of(context).textTheme.headline1!.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ))
                )
              ],
            ) : const SizedBox()
        );
      },
    );
  }
}


