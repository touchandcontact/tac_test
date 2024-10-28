import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:provider/provider.dart';
import 'package:tac/components/buttons/long_grey_button.dart';
import 'package:tac/screens/associated_card/associated_cards.dart';
import 'package:tac/services/vcard_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/my_card/ios_pass_button.dart';
import '../../constants.dart';
import '../../enums/type_action.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/toast_helper.dart';
import '../../helpers/util.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../themes/dark_theme_provider.dart';

class PremiumProfile extends StatefulWidget {
  const PremiumProfile({super.key});

  @override
  PremiumProfileState createState() => PremiumProfileState();
}

class PremiumProfileState extends State<PremiumProfile> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  void orderCard() async {
    await launchUrl(Uri.parse(Constants.orderCardUrl),
        mode: LaunchMode.externalApplication);
  }

  void goToProfile() {
    Navigator.pushNamed(context, '/editProfile');
  }

  void goToElements() {
    Navigator.pushNamed(context, '/elements');
  }

  void goToCard() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => AssociatedCards()));
  }

  void goToVirtualBackground() {
    Navigator.pushNamed(context, '/virtualBackground');
  }

  String getCompleteName(Box box, User us) {
    if (us.name != null &&
        us.name!.isNotEmpty &&
        us.surname != null &&
        us.surname!.isNotEmpty) {
      return "${us.name} ${us.surname}";
    } else {
      return us.email!;
    }
  }

  @override
  Widget build(BuildContext context) {
    DarkThemeProvider themeChangeProvider =
        Provider.of<DarkThemeProvider>(context);

    return HiveListener(
        box: Hive.box('settings'),
        builder: (box) {
          final user =
              User.fromJson(jsonDecode(box.get("user")));
          return Container(
            color: Theme.of(context).backgroundColor,
            margin: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(getCompleteName(box, user),
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.center),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  user.companyName != null && user.companyName != ""
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(user.companyName!.toString(),
                                  style: GoogleFonts.montserrat(
                                      color: HexColor.fromHex("00041F"),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center),
                            )
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 4,
                  ),
                  user.profession != null && user.profession != ""
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(user.profession!.toString(),
                                  style: Theme.of(context).textTheme.headline2),
                            )
                          ],
                        )
                      : const SizedBox(),
                  if (!user.isCompanyPremium)
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  onPressed: orderCard,
                                  style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(10),
                                      side:
                                          BorderSide(width: 1.0, color: color),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      )),
                                  child: Text(
                                    AppLocalizations.of(context)!.orderCard,
                                    style: GoogleFonts.montserrat(
                                        color: color, fontSize: 14),
                                  ))
                            ])),
                  if (user.isCompanyPremium)
                    const SizedBox(
                      height: 20,
                    ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(30, 8, 30, 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.infoProfile,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                            TextButton(
                                onPressed: goToShare,
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(18)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            color)),
                                child: Row(
                                  children: [
                                    Icon(Icons.share,
                                        size: 25,
                                        color: color.computeLuminance() > 0.5
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color
                                            : Colors.white),
                                    const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                    Text(AppLocalizations.of(context)!.share,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                color.computeLuminance() > 0.5
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .headline1!
                                                        .color
                                                    : Colors.white)),
                                    const Spacer(),
                                    Icon(Icons.chevron_right,
                                        size: 35,
                                        color: color.computeLuminance() > 0.5
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color
                                            : Colors.white)
                                  ],
                                )),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                            LongGrayButton(
                                text: AppLocalizations.of(context)!.modProfile,
                                onPress: goToProfile,
                                icon: Icons.person_outline),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                            LongGrayButton(
                                text: AppLocalizations.of(context)!.elements,
                                onPress: goToElements,
                                icon: Icons.workspaces_outline),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                            LongGrayButton(
                                text: AppLocalizations.of(context)!.myCards,
                                onPress: goToCard,
                                icon: Icons.view_day_outlined),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Platform.isIOS
                                      ? Center(
                                          child: IosPassButton(
                                              isFree: false,
                                              cardId: user.tacUserId))
                                      : GestureDetector(
                                          onTap: () {
                                            createItemGoogleWallet(
                                                user.tacUserId);
                                          },
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              child: SvgPicture.asset(
                                                "assets/images/${themeChangeProvider.locale.languageCode != "it" ? "enGB" : "it"}_add_to_google_wallet_wallet-button.svg",
                                                height: 68,
                                              )))
                                ]),
                            const SizedBox(height: 20),
                            // const Padding(
                            //     padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                            // LongGrayButton(
                            //     text: AppLocalizations.of(context)!
                            //         .virtualBackground,
                            //     onPress: goToVirtualBackground,
                            //     icon: Icons.monitor)
                          ]))
                ],
              ),
            ),
          );
        });
  }

  void goToShare() {
    Navigator.pushNamed(context, '/shareProfile');
  }

  createItemGoogleWallet(int idCard) async {
    showLoadingDialog(context);
    try {
      String response = "";
      response = await createGoogleWalletById(idCard);
      if (!mounted) return;
      Navigator.pop(context);
      Util.openLink(response, TypeAction.LINK_WEB, context);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }
}
