import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tac/components/apple_button.dart';
import 'package:tac/components/google_button.dart';
import 'package:tac/components/microsoft_button.dart';
import 'package:tac/components/tac_logo.dart';
import 'package:tac/extentions/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({Key? key}) : super(key: key);

  @override
  LoginOrSignupState createState() => LoginOrSignupState();
}

class LoginOrSignupState extends State<LoginOrSignup> {
  Color color = HexColor.fromHex("01b0b3");

  goToLogin() {
    Navigator.pushNamed(context, "/login");
  }

  goToSignUp() {
    Navigator.pushNamed(context, "/register");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Center(child: Image.asset('assets/images/welcome.png')),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                child: TacLogo(
                  forProfileImage: false,
                  color: color,
                )),
            Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  "Boost",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).textTheme.headline1!.color,
                      fontSize: 55,
                      fontWeight: FontWeight.w800),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  "Your",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).textTheme.headline1!.color,
                      fontSize: 55,
                      fontWeight: FontWeight.w800),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  "Business",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).textTheme.headline1!.color,
                      fontSize: 55,
                      fontWeight: FontWeight.w800),
                )),
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextButton(
                        onPressed: () => goToLogin(),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color),
                            side: MaterialStateProperty.all(
                                BorderSide(width: 1.0, color: color)),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.fromLTRB(100, 20, 100, 20)),
                            shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(15),
                                        right: Radius.circular(15))))),
                        child: Text(
                          AppLocalizations.of(context)!.signIn,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        )))),
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.1),
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.5),
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.9)
                              ],
                            )),
                          ),
                          Center(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                      AppLocalizations.of(context)!.or,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline1!
                                              .color)))),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.1),
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.5),
                                Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!
                                    .withOpacity(0.9)
                              ],
                            )),
                          ),
                        ]))),
            Container(
                margin: const EdgeInsets.only(top: 15),
                width: double.infinity, child: Row(
                children: [
                  const Spacer(),
                  MicrosoftButton(),
                  GoogleButton(),
                  AppleButton(),
                  const Spacer()
                ]
            )),
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
          ],
        )));
  }
}
