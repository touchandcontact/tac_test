import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/screens/profile/payment_method.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/safearea_custom.dart';
import '../../components/tac_logo.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/toast_helper.dart';
import '../../models/user.dart';
import '../../services/account_service.dart';
import '../../services/stripe_service.dart';
import '../../themes/dark_theme_provider.dart';
import '../landing.dart';

class BecamePremium extends StatefulWidget {
  const BecamePremium({super.key});

  @override
  BecamePremiumState createState() => BecamePremiumState();
}

class BecamePremiumState extends State<BecamePremium>
    with SingleTickerProviderStateMixin {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  String locale = "it";

  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _listOffersFree = [];
  List<Map<String, dynamic>> _listOffersPlus = [];
  List<Map<String, dynamic>> _listOffersPremium = [];

  _generateTextWidget(String value, Color color,
          {double fontSize = 50, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _cardSubscription(String nameSub, String priceSubMonth, String priceSubYear,
      List<Map<String, dynamic>> listSub,
      {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).secondaryHeaderColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _generateTextWidget(
                  nameSub, Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.bold, fontSize: 30),
              RichText(
                text: TextSpan(
                  text: priceSubMonth,
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headline1!.color),
                  children: <TextSpan>[
                    TextSpan(
                        text: priceSubYear,
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: listSub
                    .map<Widget>((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                color: item['isActive']
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Text(item['name'],
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: item['isActive']
                                          ? Theme.of(context)
                                              .textTheme
                                              .headline1!
                                              .color
                                          : Colors.grey)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        side: const BorderSide(
                            width: 0, color: Colors.transparent),
                      ),
                      onPressed: onPressed ?? () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 19, 8, 19),
                        child: Text(
                            AppLocalizations.of(context)!.selectPlaneLower,
                            style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 2,
              ),
            ],
          )),
    );
  }

  Widget _indicatorDot(bool isActive) {
    return AnimatedContainer(
      margin: const EdgeInsets.all(2),
      width: isActive ? 10 : 20,
      height: isActive ? 20 : 10,
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  double currentPage = 0;

  void goToPaymentMethodPage(String subType, User user) async {
    showLoadingDialog(context);

    await getUserForEdit(user.identifier).then((value) async {
      if (user.stripeId == null) {
        if (value.userDTO.stripeId == null) {
          await insertStripeAccount(user.tacUserId);
          final newUser = await getUserForEdit(user.identifier);
          await Hive.box("settings")
              .put("user", jsonEncode(newUser.userDTO.toJson()));
        } else {
          await Hive.box("settings")
              .put("user", jsonEncode(value.userDTO.toJson()));
        }
      }
    }).then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentMethod(
                    subscriptionType: subType,
                  )));
    });
  }

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!;
      });
    });
    Future.delayed(Duration.zero, () {
      DarkThemeProvider themeChangeProvider =
          Provider.of<DarkThemeProvider>(context, listen: false);
      setState(() {
        locale = themeChangeProvider.locale.languageCode;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _listOffersFree = [
      {"name": AppLocalizations.of(context)?.documents, "isActive": false},
      {"name": AppLocalizations.of(context)?.insightsT, "isActive": false},
      {"name": AppLocalizations.of(context)?.max3liks, "isActive": true},
      {"name": AppLocalizations.of(context)?.max5ocrs, "isActive": true}
    ];
    _listOffersPlus = [
      {"name": AppLocalizations.of(context)?.documents, "isActive": false},
      {"name": AppLocalizations.of(context)?.insightsT, "isActive": false},
      {"name": AppLocalizations.of(context)?.unlimitedlinks, "isActive": true},
      {"name": AppLocalizations.of(context)?.unlimitedocrs, "isActive": true}
    ];
    _listOffersPremium = [
      {"name": AppLocalizations.of(context)?.documents, "isActive": true},
      {"name": AppLocalizations.of(context)?.insightsT, "isActive": true},
      {"name": AppLocalizations.of(context)?.unlimitedlinks, "isActive": true},
      {"name": AppLocalizations.of(context)?.unlimitedocrs, "isActive": true}
    ];

    return SafeAreaCustom(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(8.8, 8, 0, 0),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        body: HiveListener(
            box: Hive.box('settings'),
            builder: (box) {
              return Container(
                  color: Theme.of(context).backgroundColor,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: TacLogo(
                          forProfileImage: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _generateTextWidget(
                                AppLocalizations.of(context)!.became,
                                Theme.of(context).textTheme.headline1!.color!,
                                fontWeight: FontWeight.bold),
                            _generateTextWidget(
                                AppLocalizations.of(context)!.premium,
                                Theme.of(context).textTheme.headline1!.color!,
                                fontWeight: FontWeight.bold),
                            const SizedBox(
                              height: 12,
                            ),
                            _generateTextWidget(
                                AppLocalizations.of(context)!.selectYourPlane,
                                Colors.grey,
                                fontSize: 16),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 260, maxHeight: 320),
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            _cardSubscription(
                                'Free',
                                '€0 / ${AppLocalizations.of(context)!.month.toLowerCase()}',
                                '  €0 / ${AppLocalizations.of(context)!.year.toLowerCase()}',
                                _listOffersFree, onPressed: () async {
                              showLoadingDialog(context);
                              await getUserForEdit(user.identifier).then(
                                  (user) async {
                                if (user.userDTO.stripeSubscription != null) {
                                  if (Platform.isIOS) {
                                    launchUrl(
                                        Uri.parse(
                                            "https://apps.apple.com/account/subscriptions"),
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    await cancelSubscription(
                                            user.userDTO.tacUserId)
                                        .then((value) {
                                      showSuccessToast(
                                          AppLocalizations.of(context)!
                                              .endSubscriptionMessage);
                                      Navigator.pop(context);
                                    }).then((value) =>
                                            Navigator.pushAndRemoveUntil<void>(
                                              context,
                                              MaterialPageRoute<void>(
                                                  builder:
                                                      (BuildContext context) =>
                                                          const Landing()),
                                              ModalRoute.withName('/'),
                                            ));
                                  }
                                } else {
                                  Navigator.pop(context);
                                }
                              }).then(
                                  (value) => Navigator.pushAndRemoveUntil<void>(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const Landing()),
                                        ModalRoute.withName('/'),
                                      ));
                            }),
                            _cardSubscription(
                                'Plus',
                                '€${locale != "it" ? "0.99" : "0,99"} / ${AppLocalizations.of(context)!.month.toLowerCase()}',
                                '  €${locale != "it" ? "9.99" : "9,99"} / ${AppLocalizations.of(context)!.year.toLowerCase()}',
                                _listOffersPlus,
                                onPressed: () =>
                                    goToPaymentMethodPage("Plus", user)),
                            _cardSubscription(
                                'Premium',
                                '€${locale != "it" ? "1.99" : "1,99"} / ${AppLocalizations.of(context)!.month.toLowerCase()}',
                                '  €${locale != "it" ? "19.99" : "19,99"}  / ${AppLocalizations.of(context)!.year.toLowerCase()}',
                                _listOffersPremium,
                                onPressed: () =>
                                    goToPaymentMethodPage("Premium", user)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                        3,
                                        (index) =>
                                            _indicatorDot(currentPage == index))
                                    .toList()),
                          ),
                        ),
                      ),
                    ],
                  ));
            }),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
