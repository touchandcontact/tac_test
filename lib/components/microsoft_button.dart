// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:sign_button/custom_image.dart';
import 'package:tac/dialogs.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tac/services/account_service.dart';
import 'package:tac/services/auth_service.dart';

class MicrosoftButton extends StatefulWidget {
  MicrosoftButton({super.key});

  @override
  State<StatefulWidget> createState() => MicrosoftButtonState();
}

class MicrosoftButtonState extends State<MicrosoftButton> {
  FlutterAppAuth appAuth = const FlutterAppAuth();

  Future login() async {
    bool canPop = false;
    final AuthorizationTokenResponse? result =
        await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        '82903949-b5e5-4e39-a4ee-ec87c720194b',
        'msauth://com.touchandcontact.tac2/mobileredirect',
        issuer:
            'https://login.microsoftonline.com/bee05f84-197e-46ab-af91-e68378427ab0/v2.0',
        discoveryUrl:
            'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
        serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint:
                'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
            tokenEndpoint:
                'https://login.microsoftonline.com/common/oauth2/v2.0/token'),
        scopes: ['openid', 'profile', 'offline_access'],
      ),
    );

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
    if (result != null) {
      var decoded = JwtDecoder.decode(result.idToken!);
      try {
        var email = decoded["email"];
        if (decoded["email"] == null) email = decoded["preferred_username"];
        var loginDto = await externalLogin(email.toString().toLowerCase());
        if (loginDto.item1.company != null &&
            (loginDto.item1.company?.stripeSubscription == null ||
                loginDto.item1.company?.stripeSubscription?.status !=
                    "active")) {
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
  }

  @override
  Widget build(BuildContext context) {
    return SignInButton.mini(
        buttonType: ButtonType.microsoft,
        customImage: CustomImage("assets/images/ms-pictogram.png"),
        btnColor: Theme.of(context).backgroundColor,
        buttonSize: ButtonSize.small,
        onPressed: login,
        elevation: 1);
  }
}
