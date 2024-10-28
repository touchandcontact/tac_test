import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:tac/screens/profile/became_premium.dart';
import 'package:tac/services/account_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/toast_helper.dart';
import '../../models/billing.dart';
import '../../models/payment_list_card.dart';
import '../../services/stripe_service.dart';
import '../components/buttons/outlinet_loading_button.dart';
import '../components/generic_dialog.dart';
import '../components/safearea_custom.dart';
import '../helpers/util.dart';
import '../models/stripe_complete_subscription_for_mobile_dto.dart';
import '../models/user.dart';
import 'payment/my_subscription_payment.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  MySubscriptionScreenState createState() => MySubscriptionScreenState();
}

class MySubscriptionScreenState extends State<MySubscriptionScreen> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  List<Map<String, dynamic>> _listOffersFree = [];
  List<Map<String, dynamic>> _listOffersPlus = [];
  List<Map<String, dynamic>> _listOffersPremium = [];

  late Future<StripeCompleteSubscriptionForMobileDto> _futureAbbonamento;
  Future<void> _futureCardScelta = Future.value();
  ValueNotifier<PaymentListCard> preferCard = ValueNotifier(PaymentListCard());
  final ValueNotifier<BillingAddress> _preferBillingAddress =
      ValueNotifier(BillingAddress());

  generateTextStyle(String value, Color color,
          {double fontSize = 50, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _emptyResult() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
      child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MySubscriptionPayment(
                          initialCard: preferCard.value,
                          user: user,
                          initialBillingAddress: _preferBillingAddress.value,
                        ))).then((value) {
              if (value != null && value[1]) {
                showSuccessToast(
                    AppLocalizations.of(context)!.operationComplete);
                refreshPage();
              } else if (value != null && value[0]) {
                refreshPage();
              }
            });
          },
          style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(width: 1.0, color: color),
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(15), right: Radius.circular(15)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add, color: color, size: 30),
            Text(
              Platform.isIOS
                  ? AppLocalizations.of(context)!.addAddress
                  : AppLocalizations.of(context)!.addCards,
              style: GoogleFonts.montserrat(
                  fontSize: 20, color: color, fontWeight: FontWeight.w600),
            )
          ])),
    );
  }

  Future<void> loadDataCard(String? defaultPaymentMethodId) async {
    try {
      await getListCard(user.stripeId!).then((value) {
        if (value.isNotEmpty) {
          preferCard.value = value.firstWhere(
              (e) => e.id == defaultPaymentMethodId,
              orElse: () => PaymentListCard());
        } else {
          preferCard.value = PaymentListCard();
        }
      });
    } catch (e) {
      throw Exception();
    }
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 50, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _cardSubscription(
      String nameSub, String priceSubMonth, List<Map<String, dynamic>> listSub,
      {VoidCallback? onPressed}) {
    return Container(
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
                                  ? Theme.of(context).textTheme.headline1!.color
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
              height: 22,
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
                      side:
                          const BorderSide(width: 0, color: Colors.transparent),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BecamePremium())),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
                      child: Text(AppLocalizations.of(context)!.changePlane,
                          style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: color.computeLuminance() > 0.5
                                  ? Theme.of(context).textTheme.bodyText2!.color
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
        ));
  }

  Future<StripeCompleteSubscriptionForMobileDto> loadData() async {
    try {
      return getCurrentSubscription(user.tacUserId)
          .then((StripeCompleteSubscriptionForMobileDto value) {
        if (value != null && value.billingAddress != null) {
          _preferBillingAddress.value = value.billingAddress!;
        } else {
          _preferBillingAddress.value = BillingAddress();
        }
        _futureCardScelta = loadDataCard(value.defaultPaymentMethodId);
        return value;
      });
    } catch (e) {
      throw Exception();
    }
  }

  @override
  void initState() {
    _futureAbbonamento = loadData();
    super.initState();
  }

  refreshPage() {
    setState(() {
      _futureAbbonamento = loadData();
    });
  }

  String getInterval(String value) {
    String label = "";
    switch (value) {
      case "month":
        label = " / ${AppLocalizations.of(context)!.payInMonthly}";
        break;
      default:
        label = " / ${AppLocalizations.of(context)!.payYearly}";
    }
    return label;
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
          title: Text(AppLocalizations.of(context)!.mySubscription,
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headline1!.color)),
          centerTitle: true,
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
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      child: Column(
                        children: [
                          if(!Platform.isIOS)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.selectedCard,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .color)),
                            ],
                          ),
                          if(!Platform.isIOS)
                          const SizedBox(
                            height: 12,
                          ),
                          FutureBuilder<dynamic>(
                              future: Future.wait(
                                  [_futureAbbonamento, _futureCardScelta]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                            color:
                                                Theme.of(context).primaryColor),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.5))
                                      ],
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  showErrorToast(
                                      AppLocalizations.of(context)!.error);
                                  return Text(
                                      AppLocalizations.of(context)!.error);
                                }
                                return ValueListenableBuilder<PaymentListCard>(
                                    valueListenable: preferCard,
                                    builder: (context, value, child) =>
                                        value.id != null && value.id!.isNotEmpty
                                            ? _createListRowCard(value)
                                            : Column(
                                                children: [
                                                  _emptyResult(),
                                                  _createListRowCard(null)
                                                ],
                                              ));
                              }),
                          ValueListenableBuilder(
                            valueListenable: _preferBillingAddress,
                            builder: (context, valueNotifier, child) {
                              if (valueNotifier.shipmentAddressId == null) {
                                return Text(
                                  AppLocalizations.of(context)!
                                      .noShippingBilling,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .color),
                                );
                              } else {
                                return RichText(
                                  text: TextSpan(
                                    text:
                                        '${AppLocalizations.of(context)!.billingAddress}: ',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline1!
                                            .color),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '${valueNotifier.address}${valueNotifier.number != null ? " ${valueNotifier.number}" : ""},${valueNotifier.city} (${valueNotifier.province})',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline1!
                                                  .color)),
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Text(AppLocalizations.of(context)!.mySubscription,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const SizedBox(
                              height: 12,
                            ),
                            FutureBuilder<
                                    StripeCompleteSubscriptionForMobileDto>(
                                future: _futureAbbonamento,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(height: 0);
                                  }
                                  if (snapshot.hasError) {
                                    showErrorToast(
                                        AppLocalizations.of(context)!.error);
                                    return Text(
                                        AppLocalizations.of(context)!.error);
                                  }
                                  return Column(
                                    children: [
                                      _cardSubscription(
                                          snapshot.data!.productName ?? "---",
                                          "€ ${snapshot.data!.priceAmount.toString().replaceAll(".", ",")} / ${Util.translatePeriodPayment(snapshot.data!.pricePeriod!, context)}",
                                          snapshot.data!.productName == null ||
                                                  (snapshot.data!.productName !=
                                                          "Premium" &&
                                                      snapshot.data!
                                                              .productName !=
                                                          "Plus ")
                                              ? _listOffersFree
                                              : (snapshot.data!.productName ==
                                                      "Premium"
                                                  ? _listOffersPremium
                                                  : _listOffersPlus)),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                ),
                                                side: const BorderSide(
                                                    width: 0,
                                                    color: Colors.transparent),
                                              ),
                                              onPressed: () {
                                                if(Platform.isIOS){
                                                  launchUrl(Uri.parse("https://apps.apple.com/account/subscriptions"), mode: LaunchMode.externalApplication);
                                                }
                                                else{
                                                  showDeleteDialog();
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 22, 8, 22),
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .deleteSubscription,
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            color.computeLuminance() >
                                                                    0.5
                                                                ? Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText2!
                                                                    .color
                                                                : Colors
                                                                    .white)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        )),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
              vertical: Platform.isAndroid
                  ? 240
                  : (MediaQuery.of(context).size.height > 845 ? 250 : 230),
              child: deleteDialog());
        });
  }

  Widget deleteDialog() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteSubscription}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteSubscriptionProceded}?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: OutlinedLoadingButton(
                  color: Colors.red,
                  borderColor: Colors.red,
                  onPress: deleteSub,
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                ))
          ],
        ));
  }

  Future deleteSub() async {
    try {
      await cancelSubscription(user.tacUserId);
      await Util.updateUserInHive(user.identifier);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      showSuccessToast(AppLocalizations.of(context)!.endSubscriptionMessage);
      await refreshPage();
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  dialog(String tipo) {
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(children: [
            Icon(Icons.circle_outlined,
                size: 120, color: tipo == "err" ? Colors.red : color),
            Positioned(
                left: 20,
                top: 20,
                child: Icon(
                  tipo == "err" ? Icons.close : Icons.check,
                  size: 80,
                  color: tipo == "err" ? Colors.red : color,
                ))
          ])),
      Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: ListTile(
          minVerticalPadding: 10,
          title: RichText(
              text: TextSpan(
            text: tipo == "err"
                ? "     ${AppLocalizations.of(context)!.ops}!"
                : AppLocalizations.of(context)!.paySuccess,
            style: GoogleFonts.montserrat(
                fontSize: tipo == "err" ? 30 : 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1!.color),
          )),
          subtitle: generateTextStyle(
              tipo == "err"
                  ? "${AppLocalizations.of(context)!.payError},"
                      "\n                ${AppLocalizations.of(context)!.tryLater}"
                  : "",
              Colors.grey,
              fontSize: 12),
        ),
      ),
      const SizedBox(height: 80)
    ]));
  }

  Future checkBillingAddress() async {
    if (_preferBillingAddress.value.id == null) {
      showErrorToast(AppLocalizations.of(context)!.addShippingBillingAddress);
      return false;
    }
    try {
      return await updateStripeBilling(
          user.tacUserId, _preferBillingAddress.value.id!);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
    return false;
  }

  _returnRightIcon(String? type) {
    if (type == "google_pay") {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FaIcon(
              FontAwesomeIcons.googlePay,
              size: 40,
            ),
          ),
        ],
      );
    } else if (type == "apple_pay") {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FaIcon(
              FontAwesomeIcons.applePay,
              size: 40,
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _createListRowCard(PaymentListCard? paymentCard) {
    return Column(
      children: [
        paymentCard != null
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MySubscriptionPayment(
                                initialBillingAddress:
                                    _preferBillingAddress.value,
                                initialCard: preferCard.value,
                                user: user,
                              ))).then((value) {
                    if (value != null && value[1]) {
                      showSuccessToast(
                          AppLocalizations.of(context)!.operationComplete);
                      refreshPage();
                    } else if (value != null && value[0]) {
                      refreshPage();
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  height: 120,
                  decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    trailing: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1)),
                        child: const Icon(Icons.edit, color: Colors.white)),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        paymentCard.card?.wallet?.type == "google_pay" ||
                                paymentCard.card?.wallet?.type == "apple_pay"
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Text("Pagato con",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color)),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        _returnRightIcon(paymentCard.card?.wallet?.type),
                        paymentCard.card?.wallet?.type != "google_pay" &&
                                paymentCard.card?.wallet?.type != "apple_pay"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  paymentCard.card!.brand! == "mastercard"
                                      ? const FaIcon(
                                          FontAwesomeIcons.ccMastercard,
                                          size: 50,
                                        )
                                      : paymentCard.card!.brand! == "visa"
                                          ? const FaIcon(
                                              FontAwesomeIcons.ccVisa,
                                              size: 50,
                                            )
                                          : paymentCard.card!.brand! ==
                                                  "american express"
                                              ? const FaIcon(
                                                  FontAwesomeIcons.ccAmex,
                                                  size: 50,
                                                )
                                              : const SizedBox(),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  RichText(
                                      text: TextSpan(
                                    text: "${paymentCard.billingDetails?.name}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline1!
                                            .color),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                        paymentCard.card?.wallet?.type != "google_pay" &&
                                paymentCard.card?.wallet?.type != "apple_pay"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(
                                    text:
                                        " **********${paymentCard.card?.last4}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .color),
                                  )),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
