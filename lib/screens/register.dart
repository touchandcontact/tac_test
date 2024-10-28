import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/confirm_slider.dart';
import '../components/inputs/input_text.dart';
import '../constants.dart';
import '../extentions/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:email_validator/email_validator.dart';

import '../helpers/util.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  Color color = HexColor.fromHex("01b0b3");

  bool passwordVisible = false;
  bool repeatPasswordVisible = false;
  bool privacy = false;
  String username = "";
  String password = "";
  String repeatPassword = "";
  bool showSuccess = false;

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      if(!privacy){
        showErrorToast(AppLocalizations.of(context)!.mustAcceptPrivacy);
        return;
      }
      try {
        await signUp(username, password);
        setState(() {
          showSuccess = true;
        });
      } catch (_) {
        showErrorToast(AppLocalizations.of(context)!.error);
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

  void changeRepeatPassword(String val) {
    setState(() {
      repeatPassword = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: showSuccess
            ? SingleChildScrollView(
                child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Icon(
                              Icons.check_circle_outline,
                              color: color,
                              size: 120,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                              child: Text(
                                AppLocalizations.of(context)!.thanksForSignUp,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Center(
                                  child: TextButton(
                                      onPressed: () => Navigator.pushReplacementNamed(
                                          context, "/login"),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(color),
                                          side: MaterialStateProperty.all(BorderSide(
                                              width: 1.0, color: color)),
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.fromLTRB(
                                                  100, 20, 100, 20)),
                                          shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.horizontal(
                                                  left: Radius.circular(15),
                                                  right: Radius.circular(15))))),
                                      child: Text(
                                        AppLocalizations.of(context)!.signIn,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ))))
                        ])))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset('assets/images/registrati.png')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                child: Text(
                                  AppLocalizations.of(context)!.signUp,
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
                                height: 10,
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
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    return Util.validatorPassword(context, value);
                                  },
                                  enableInteractiveSelection: false,
                                  obscureText: !passwordVisible),
                              Container(height: 10),
                              InputText(
                                  label: AppLocalizations.of(context)!
                                      .repeatPassword,
                                  enabled: password != "",
                                  onChange: changeRepeatPassword,
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
                                      setState(() {
                                        repeatPasswordVisible =
                                            !repeatPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value == "") {
                                      return AppLocalizations.of(context)!
                                          .requiredField;
                                    }
                                    if (value != password) {
                                      return AppLocalizations.of(context)!
                                          .passwordNotMatch;
                                    }

                                    return null;
                                  },
                                  enableInteractiveSelection: false,
                                  obscureText: !repeatPasswordVisible),
                              const SizedBox(height: 10),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  title: Row(children: [
                                    Text(
                                        AppLocalizations.of(context)!.acceptThe,
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500,)),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () async{
                                        if(await canLaunchUrl(Uri.parse(Constants.privacyUrl))){
                                          await launchUrl(Uri.parse(Constants.privacyUrl));
                                        }
                                      },
                                        child: Text("Privacy Policy",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor)))
                                  ]),
                                  value: privacy,
                                  onChanged: (value) {
                                    setState(() {
                                      privacy = value ?? false;
                                    });
                                  }),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: ConfirmSlider(
                                      slideText:
                                          AppLocalizations.of(context)!.signUp,
                                      backText: "Swipe",
                                      onSwipeFinish: register)),
                            ])),
                        // ignore: prefer_const_constructors
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${AppLocalizations.of(context)!.alreadyHaveAccount}?",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                          Navigator.pushNamed(
                                              context, '/login');
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.signIn,
                                        style: GoogleFonts.montserrat(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .color,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline),
                                        textAlign: TextAlign.center,
                                      ))
                                ]))
                      ],
                    ),
                  )
                ],
              )));
  }

}
