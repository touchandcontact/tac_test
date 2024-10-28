import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:tac/models/user.dart';
import 'package:tac/screens/loginorsignup.dart';
import 'package:tac/services/notification_service.dart';
import '../bottom_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../components/safearea_custom.dart';
import '../extentions/pars_bool.dart';
import '../services/account_service.dart';
import '../services/token_service.dart';
import '../services/vcard_service.dart';
import '../services/navigation_service.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  LandingState createState() => LandingState();
}

class LandingState extends State<Landing> with TickerProviderStateMixin {
  late Future<bool> _isLoggedInFuture;
  String? _identifier;
  late AnimationController controller;

  Future<bool> initScreen() async {
    if (!Hive.isBoxOpen(("settings"))) await Hive.openBox("settings");

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    final lastVersion = Hive.box("settings").get('last_version');

    if (lastVersion == null || lastVersion != currentVersion) {
      await Hive.box("settings").put('last_version', currentVersion);
      await Hive.box("settings").put('isLoggedIn', false);

      var boxUser = Hive.box("settings").get("user");
      if(boxUser != null){
        User user = User.fromJson(jsonDecode(boxUser));
        await logOut(user);
        if (!Hive.isBoxOpen(("settings"))) await Hive.openBox("settings");
        await Hive.box("settings").put('last_version', currentVersion);

        return false;
      }
    }

    var boxIsLoggedIn = Hive.box("settings").get('isLoggedIn');
    var isLoggedIn =
        (boxIsLoggedIn == null) ? false : boxIsLoggedIn.toString().parseBool();
    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      await NotificationService().init();
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      try {
        User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
        await getUserForEdit(user.identifier).then((user) async {
          _identifier = user.userDTO.identifier;
          await Hive.box("settings")
              .put("user", jsonEncode(user.userDTO.toJson()));
          await TokenService().saveUserDeviceFunction(user.userDTO.tacUserId);
          if(_identifier != null && _identifier!.isNotEmpty){
            final value = await createVCardStringWithIdentifier(_identifier!);
            await Hive.box("settings").put("qrCodeOffline", value);
          }
        });
      } catch (e) {
        await Hive.box("settings").clear();
        debugPrint(e.toString());
      }
    }
    return isLoggedIn;
  }

   logOut(User user) async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await logoutFromDevice(user.tacUserId, token);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    await Hive.deleteFromDisk();
  }

  @override
  void initState() {
    _isLoggedInFuture = initScreen();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _isLoggedInFuture,
            builder: (context, snapshotLoggedIn) {
              if (!snapshotLoggedIn.hasData) {
                return Container(
                    color: Theme.of(context).backgroundColor,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Center(
                            child: Image(
                                image: AssetImage("assets/images/logo_tac_splash.png"),
                                width:  227)),
                        Center(
                            child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(top: 20),
                                child: LinearProgressIndicator(
                                    value: controller.value,
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.4),
                                    color: Theme.of(context).primaryColor))),
                        const Spacer(),
                      ],
                    ));
              }
              return SafeAreaCustom(
                isHome: true,
                child: Scaffold(
                    body: snapshotLoggedIn.data != null &&
                        snapshotLoggedIn.data!
                        ? const BottomNavigation()
                        : const LoginOrSignup()),
              );
            }));
  }
}
