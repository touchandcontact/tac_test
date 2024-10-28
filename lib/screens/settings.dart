// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/generic_dialog.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/constants.dart';
import 'package:tac/extentions/hexcolor.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/user.dart';
import 'package:tac/screens/delete_account_screen.dart';
import 'package:tac/screens/profile/became_premium.dart';
import 'package:tac/screens/reset_password.dart';
import 'package:tac/screens/select_language.dart';
import 'package:tac/services/account_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/appbars/settings_app_bar.dart';
import '../components/buttons/settings_button.dart';
import '../dialogs.dart';
import 'landing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'my_subscription_screen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  String email = "";

  @override
  void initState() {
    email = user.accessEmail;
    super.initState();
  }

  void changeEmail(String? value) {
    email = value ?? "";
  }

  Future<void> saveEmail() async {
    if (email.isEmpty) {
      showErrorToast(AppLocalizations.of(context)!.insertEmail);
      return;
    }

    if (!EmailValidator.validate(email)) {
      showErrorToast(AppLocalizations.of(context)!.insertValidEmail);
      return;
    }

    try {
      await updateUserAccountEmail(user.identifier, email);
      Navigator.of(context).pop();

      await Hive.box("settings").put("user", jsonEncode(user.toJson()));
      showSuccessToast(AppLocalizations.of(context)!.saveEmailComplete);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.genericError);
    }
  }

  void openEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(vertical: 220, child: getEmailDialog());
        });
  }

  Future<void> logOut() async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await logoutFromDevice(user.tacUserId, token);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    await Hive.deleteFromDisk()
        .then((value) => Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => const Landing()),
              ModalRoute.withName('/'),
            ));
  }

  void goToDeleteAccount() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DeleteAccountScreen(identifier: user.identifier)));
  }

  void goRestPassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ResetPassword()));
  }

  void goToLanguage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SelectLanguage()));
  }

  void goTo() async {
    if (await canLaunchUrl(Uri.parse(Constants.privacyUrl))) {
      await launchUrl(Uri.parse(Constants.privacyUrl),
          mode: LaunchMode.externalApplication); //forceWebView is true now
    } else {
      showErrorDialog(context, AppLocalizations.of(context)!.attention,
          AppLocalizations.of(context)!.linkError);
    }
  }

  void goToProfile() {
    Navigator.pushNamed(context, "/editProfile");
  }

  void goToPremium() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MySubscriptionScreen()));
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: logoutDialog(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return HiveListener(
        box: Hive.box('settings'),
        builder: (box) {
          return Scaffold(
            appBar: const SettingsAppBar(height: 80),
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.90,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!user.isCompanyPremium)
                                  SettingsButton(
                                    consumer: false,
                                    subText: AppLocalizations.of(context)!
                                        .associatedEmail,
                                    text: user.accessEmail,
                                    onPress: openEmailDialog,
                                  ),
                                if (!user.isCompanyPremium)
                                  const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                SettingsButton(
                                  consumer: false,
                                  text: AppLocalizations.of(context)!
                                      .resetPassword,
                                  onPress: goRestPassword,
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                user.isCompanyPremium
                                    ? const SizedBox()
                                    : (!user.subscriptionGifted &&
                                                user.subscriptionType != null &&
                                                (user.subscriptionType == 2 ||
                                                    user.subscriptionType ==
                                                        1)) &&
                                            !user.isCompanyPremium
                                        ? SettingsButton(
                                            consumer: false,
                                            text: AppLocalizations.of(context)!
                                                .mySubscription,
                                            onPress: goToPremium,
                                          )
                                        : (!user.subscriptionGifted &&
                                                    user.subscriptionType ==
                                                        null ||
                                                user.subscriptionType == 0)
                                            ? TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const BecamePremium()));
                                                },
                                                style: ButtonStyle(
                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10))),
                                                    padding:
                                                        MaterialStateProperty.all(
                                                            const EdgeInsets.all(18)),
                                                    backgroundColor: MaterialStateProperty.all<Color>(color)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.white,
                                                      ),
                                                      height: 25,
                                                      width: 25,
                                                      child: Icon(Icons.star,
                                                          size: 14,
                                                          color: color),
                                                    ),
                                                    const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0)),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .becamePro,
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white)),
                                                          Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .proBenefits,
                                                              style: GoogleFonts.montserrat(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons
                                                            .arrow_forward_sharp,
                                                        size: 30,
                                                        color: Colors.white)
                                                  ],
                                                ))
                                            : const SizedBox(),
                                user.isCompanyPremium
                                    ? const SizedBox()
                                    : ((user.subscriptionType != null &&
                                                    user.subscriptionType ==
                                                        2) &&
                                                !user.isCompanyPremium) ||
                                            !user.isCompanyPremium
                                        ? const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0))
                                        : const SizedBox(),
                                // SettingsButton(
                                //   consumer: true,
                                //   text: "Dark Mode",
                                //   onPress: goTo,
                                // ),
                                // const Padding(
                                //     padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                // SettingsButton(
                                //   consumer: false,
                                //     text: AppLocalizations.of(context)!.becameAffiliate,
                                //     onPress: goTo,
                                // ),
                                // const Padding(
                                //     padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                SettingsButton(
                                  consumer: false,
                                  text: AppLocalizations.of(context)!.privacy,
                                  onPress: goTo,
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                SettingsButton(
                                  consumer: false,
                                  text: AppLocalizations.of(context)!.language,
                                  onPress: goToLanguage,
                                ),
                                // const Padding(
                                //     padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                // SettingsButton(
                                //   consumer: false,
                                //     text: AppLocalizations.of(context)!.faq,
                                //     onPress: goTo,
                                // ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                SettingsButton(
                                  consumer: false,
                                  text: AppLocalizations.of(context)!.logout,
                                  onPress: showLogoutDialog,
                                  icon: Icons.logout,
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                SettingsButton(
                                  consumer: false,
                                  text: AppLocalizations.of(context)!
                                      .deleteAccount,
                                  onPress: goToDeleteAccount,
                                  icon: Icons.delete,
                                  colorIcon: Colors.redAccent,
                                  colorText: Colors.redAccent,
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                              ]))
                    ],
                  )),
            ),
          );
        });
  }

  Widget logoutDialog() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text("${AppLocalizations.of(context)!.attention}",
                style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headline1!.color))),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text("${AppLocalizations.of(context)!.logoutDialogText}",
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headline1!.color))),
        const SizedBox(
          height: 24,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.headline1!.color,
                  side: BorderSide(
                      width: 1.0,
                      color: Theme.of(context).textTheme.headline1!.color!),
                  padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                          right: Radius.circular(15)))),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontWeight: FontWeight.w600),
              )),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: logOut,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(width: 1.0, color: Colors.redAccent),
                  padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                          right: Radius.circular(15)))),
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600),
              )),
        ),
      ],
    );
  }

  Widget getEmailDialog() {
    return Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * .5,
        child: Column(children: [
          Text(AppLocalizations.of(context)!.editEmail,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headline3!.color)),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.editEmailText,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.headline2!.color)),
          const SizedBox(height: 20),
          InputText(
              label: AppLocalizations.of(context)!.email,
              initalValue: email,
              onChange: changeEmail),
          const SizedBox(height: 20),
          LoadingButton(
              onPress: saveEmail,
              text: AppLocalizations.of(context)!.save,
              color: color,
              borderColor: color)
        ]));
  }
}
