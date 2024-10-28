// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tac/components/inputs/input_code.dart';
import 'package:tac/helpers/toast_helper.dart';
import '../components/confirm_slider.dart';
import '../components/inputs/input_text.dart';
import '../helpers/util.dart';
import '../services/auth_service.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final formKey = GlobalKey<FormState>();
  final emailKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool repeatPasswordVisible = false;
  bool canReset = false;
  bool mustInsertEmail = true;
  int? code1;
  int? code2;
  int? code3;
  int? code4;
  int? code5;
  int? code6;
  String password = "";
  String repeatPassword = "";
  String email = "";

  Future verifyCode() async {
    if (code1 == null ||
        code2 == null ||
        code3 == null ||
        code4 == null ||
        code5 == null ||
        code6 == null) {
      showErrorToast(AppLocalizations.of(context)!.codeError);
    } else {
      try {
        var result =
            await checkCode(email, "$code1$code2$code3$code4$code5$code6");
        if (result) {
          setState(() {
            canReset = true;
          });
        } else {
          showErrorToast(AppLocalizations.of(context)!.codeNotValid);
        }
      } catch (_) {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    }
  }

  Future verifyEmail() async {
    try {
      if (emailKey.currentState!.validate()) {
        await resetPassword(email);
        setState(() {
          mustInsertEmail = false;
        });
      }
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  Future sendPassword() async {
    try {
      if (formKey.currentState!.validate()) {
        await updatePassword(email, password);
        showSuccessToast(AppLocalizations.of(context)!.changePassword);
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  void changeEmail(String val) {
    setState(() {
      email = val;
    });
  }

  void changeCode(String val) {
    setState(() {
      code1 = val.isEmpty ? null : int.parse(val);
    });
    FocusScope.of(context).nextFocus();
  }

  void changeCode2(String val) {
    setState(() {
      code2 = val.isEmpty ? null : int.parse(val);
    });
    FocusScope.of(context).nextFocus();
  }

  void changeCode3(String val) {
    setState(() {
      code3 = val.isEmpty ? null : int.parse(val);
    });
    FocusScope.of(context).nextFocus();
  }

  void changeCode4(String val) {
    setState(() {
      code4 = val.isEmpty ? null : int.parse(val);
    });
    FocusScope.of(context).nextFocus();
  }

  void changeCode5(String val) {
    setState(() {
      code5 = val.isEmpty ? null : int.parse(val);
    });
    FocusScope.of(context).nextFocus();
  }

  void changeCode6(String val) {
    setState(() {
      code6 = val.isEmpty ? null : int.parse(val);
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

  String obfuscateEmail(String val) {
    String first2 = val.substring(0, 2);
    int untilAt = val.substring(2, val.indexOf("@")).length;
    String ext = val.substring(val.lastIndexOf(".") + 1);
    String obscuredFirstPart = "";
    String obscuredSecondPart = "";

    for (var i = 0; i < untilAt; i++) {
      obscuredFirstPart += "*";
    }

    untilAt = val.substring(val.indexOf("@"), val.lastIndexOf(".")).length;

    for (var i = 0; i < untilAt; i++) {
      obscuredSecondPart += "*";
    }

    return "$first2$obscuredFirstPart@$obscuredSecondPart.$ext";
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
              padding: const EdgeInsets.fromLTRB(8.8, 40, 0, 0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
            Center(
                child: Image.asset(canReset
                    ? "assets/images/resetpassword2.png"
                    : 'assets/images/resetpassword.png', width: 350)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Column(
                children: canReset
                    ? [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                child: Text(
                                  AppLocalizations.of(context)!.resetPassword,
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ))),
                        Form(
                            key: formKey,
                            child: Column(children: [
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
                                      repeatPasswordVisible
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
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: ConfirmSlider(
                                      slideText: AppLocalizations.of(context)!
                                          .continueOperation,
                                      backText: "Swipe",
                                      onSwipeFinish: sendPassword)),
                            ]))
                      ]
                    : (mustInsertEmail
                        ? [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .resetPassword,
                                      maxLines: 2,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold),
                                    ))),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppLocalizations.of(context)!.insertEmail,
                                  style: GoogleFonts.montserrat(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                )),
                            Container(height: 30),
                            Form(
                                key: emailKey,
                                child: InputText(
                                    label: AppLocalizations.of(context)!.email,
                                    onChange: changeEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }
                                      if (!RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+")
                                          .hasMatch(value)) {
                                        return AppLocalizations.of(context)!
                                            .insertValidEmail;
                                      }

                                      return null;
                                    })),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: ConfirmSlider(
                                    slideText: AppLocalizations.of(context)!
                                        .continueOperation,
                                    backText: "Swipe",
                                    onSwipeFinish: verifyEmail)),
                          ]
                        : [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .resetPassword,
                                      maxLines: 2,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold),
                                    ))),
                            Text(
                              "${AppLocalizations.of(context)!.insertCode}: ${obfuscateEmail(email)}",
                              style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color,
                                  fontSize: 16),
                            ),
                            Container(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode,
                                            textInputAction:
                                                TextInputAction.next))),
                                Container(width: 5),
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode2,
                                            textInputAction:
                                                TextInputAction.next))),
                                Container(width: 5),
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode3,
                                            textInputAction:
                                                TextInputAction.next))),
                                Container(width: 5),
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode4,
                                            textInputAction:
                                                TextInputAction.next))),
                                Container(width: 5),
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode5,
                                            textInputAction:
                                                TextInputAction.done))),
                                Container(width: 5),
                                Expanded(
                                    child: SizedBox(
                                        child: InputCode(
                                            onChange: changeCode6,
                                            textInputAction:
                                                TextInputAction.done)))
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: ConfirmSlider(
                                    slideText: AppLocalizations.of(context)!
                                        .continueOperation,
                                    backText: "Swipe",
                                    onSwipeFinish: verifyCode)),
                          ]),
              ),
            )
          ],
        )));
  }
}
