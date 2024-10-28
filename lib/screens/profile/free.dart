import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tac/components/buttons/long_grey_button.dart';
import 'package:tac/constants.dart';
import 'package:tac/screens/associated_card/associated_cards.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/my_card/ios_pass_button.dart';
import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import '../../themes/dark_theme_provider.dart';
import 'became_premium.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FreeProfile extends StatefulWidget {
  const FreeProfile({super.key});

  @override
  FreeProfileState createState() => FreeProfileState();
}

class FreeProfileState extends State<FreeProfile> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  void orderCard() async {
    await launchUrl(Uri.parse(Constants.orderCardUrl),
        mode: LaunchMode.externalApplication);
  }

  void goToProfile() async {
    Navigator.pushNamed(context, '/editProfile');
  }

  void goToElements() {
    Navigator.pushNamed(context, '/elements');
  }

  void goToCard() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => AssociatedCards()));
  }

  void goToShare() {
    Navigator.pushNamed(context, '/shareProfile');
  }

  void goToSubscription() {
    if(user.subscriptionGifted) return;

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const BecamePremium()));
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

    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, box, widget) {
          final user =
              User.fromJson(jsonDecode(Hive.box("settings").get("user")));
          return Container(
              color: Theme.of(context).backgroundColor,
              margin: const EdgeInsets.only(top: 30),
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
                                    style:
                                        Theme.of(context).textTheme.headline2),
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
                                        side: BorderSide(
                                            width: 1.0, color: color),
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
                    Container(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(!user.subscriptionGifted)
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BecamePremium()));
                                  },
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
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        height: 25,
                                        width: 25,
                                        child: Icon(Icons.star,
                                            size: 14, color: color),
                                      ),
                                      const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)!
                                                    .becamePro,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                            Text(
                                                AppLocalizations.of(context)!
                                                    .proBenefits,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right,
                                          size: 35, color: Colors.white)
                                    ],
                                  )),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(AppLocalizations.of(context)!.infoProfile,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .color)),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
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
                                  text:
                                      AppLocalizations.of(context)!.modProfile,
                                  onPress: goToProfile,
                                  icon: Icons.person_outline),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                              LongGrayButton(
                                  text: AppLocalizations.of(context)!.elements,
                                  onPress: goToElements,
                                  fontSize: 16,
                                  icon: Icons.workspaces_outline),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                              LongGrayButton(
                                  text: AppLocalizations.of(context)!.myCards,
                                  onPress: goToCard,
                                  icon: Icons.view_day_outlined),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
                              const SizedBox(height: 20),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Platform.isIOS
                                        ? Center(
                                            child: IosPassButton(
                                                isFree: !user.subscriptionGifted,
                                                cardId: user.tacUserId))
                                        : GestureDetector(
                                            onTap: goToSubscription,
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
                            ]))
                  ],
                ),
              ));
        });
  }
}
