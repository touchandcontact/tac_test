// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:tac/dialogs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/services/account_service.dart';
import 'package:tac/services/auth_service.dart';

class GoogleButton extends StatefulWidget {
  GoogleButton({super.key});

  @override
  State<StatefulWidget> createState() => GoogleButtonState();
}

class GoogleButtonState extends State<GoogleButton> {
  late GoogleSignIn oauth;

  @override
  void initState() {
    oauth = GoogleSignIn(scopes: ["email"]);

    super.initState();
  }

  Future login() async {
    bool canPop = false;

    try {
      var res = await oauth.signIn();
      if (res == null) throw Exception();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Column(children: [
                  Text(AppLocalizations.of(context)!.doingLogin),
                  const SizedBox(
                    height: 8,
                  ),
                  const SizedBox(
                      height: 45, width: 45, child: CircularProgressIndicator())
                ]),
              ));

      canPop = true;
      var loginDto = await externalLogin(res.email);
      if (loginDto.item1.company != null &&
          (loginDto.item1.company?.stripeSubscription == null ||
              loginDto.item1.company?.stripeSubscription?.status != "active")) {
        Navigator.pop(context);
        showErrorDialog(context, AppLocalizations.of(context)!.attention,
            AppLocalizations.of(context)!.noCompanySub);
        return;
      }

      await Hive.box("settings")
          .put("user", jsonEncode(loginDto.item1.toJson()));
      await Hive.box("settings").put("token", loginDto.item2);
      await Hive.box("settings").put('isLoggedIn', true);
      await Hive.box("settings")
          .put('color', loginDto.item1.company?.color ?? "01b0b3");

      if (loginDto.item1.isCompanyPremium) {
        var vb = await getVirtualBackground(loginDto.item1.tacUserId);
        loginDto.item1.coverImage = vb.image;
      }
      Navigator.pop(context);
      await Navigator.pushNamedAndRemoveUntil(
          context, "/", (Route<dynamic> route) => false);
    } catch (e) {
      if(canPop) Navigator.pop(context);
      if (e.toString().contains("NOT_FOUND")) {
        showErrorDialog(context, AppLocalizations.of(context)!.attention,
            AppLocalizations.of(context)!.userNotFound);
      } else if (e.toString().contains("USER_INACTIVE")) {
        showErrorDialog(context, AppLocalizations.of(context)!.attention,
            AppLocalizations.of(context)!.inactiveUser);
      } else {
        showErrorDialog(context, AppLocalizations.of(context)!.attention,
            AppLocalizations.of(context)!.genericError);
      }
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignInButton.mini(
        buttonType: ButtonType.google,
        btnColor: Theme.of(context).backgroundColor,
        buttonSize: ButtonSize.small,
        onPressed: login,
        elevation: 1);
  }
}
