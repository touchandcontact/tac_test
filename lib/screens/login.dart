// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/confirm_slider.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/dialogs.dart';
import 'package:tac/services/auth_service.dart';
import '../services/account_service.dart';
import '../services/vcard_service.dart';
import 'package:email_validator/email_validator.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool rememberMe = false;
  String username = "";
  String password = "";

  @override
  void initState() {

    super.initState();
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        var loginDto = await signIn(username, password, rememberMe);
        if (loginDto.item1.company != null &&
            (loginDto.item1.company?.stripeSubscription == null ||
                loginDto.item1.company?.stripeSubscription?.status !=
                    "active")) {
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
        try{
          if(loginDto.item1.identifier != null && loginDto.item1.identifier.isNotEmpty){
            final value = await createVCardStringWithIdentifier(loginDto.item1.identifier);
            await Hive.box("settings").put("qrCodeOffline", value);
          }
        }catch(e) {

        }
          await Navigator.pushNamedAndRemoveUntil(context, "/", (Route<dynamic> route) => false);
      } on Exception catch (e) {
        debugPrint("ERROR: $e");

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
      }
    }
    return;
  }

  void changeUsername(String val) {
    setState(() {
      username = val;
    });
  }

  void changePassword(String val) {
    setState(() {
      password = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Theme.of(context).backgroundColor),
        backgroundColor: Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/images/login.png')),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: Text(
                            AppLocalizations.of(context)!.signIn,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ))),
                  Form(
                      key: formKey,
                      child: Column(children: [
                        InputText(
                            label: AppLocalizations.of(context)!.email,
                            onChange: changeUsername,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              if (!EmailValidator.validate(value)) {
                                return AppLocalizations.of(context)!
                                    .insertValidEmail;
                              }

                              return null;
                            }),
                        Container(
                          height: 20,
                        ),
                        InputText(
                            label: AppLocalizations.of(context)!.password,
                            onChange: changePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                            enableInteractiveSelection: false,
                            obscureText: !passwordVisible)
                      ])),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Row(children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Theme.of(context).primaryColor,
                                  value: rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberMe = value!;
                                    });
                                  },
                                )),
                            Transform.translate(
                                offset: const Offset(-10, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rememberMe = !rememberMe;
                                    });
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.rememberMe,
                                      style: GoogleFonts.montserrat(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline2!
                                              .color)),
                                )),
                          ])),
                      Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  Navigator.pushNamed(
                                      context, "/resetPassword");
                                });
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.recoverPassword,
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .color,
                                      decoration: TextDecoration.underline))))
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ConfirmSlider(
                          slideText: AppLocalizations.of(context)!.signIn,
                          backText: "Swipe",
                          onSwipeFinish: login)),
                  // ignore: prefer_const_constructors
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.noAccountQUestion,
                              style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              width: 5,
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pushNamed(context, '/register');
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.signUp,
                                  style: GoogleFonts.montserrat(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  textAlign: TextAlign.center,
                                ))
                          ]))
                ]))
          ],
        )));
  }
}
