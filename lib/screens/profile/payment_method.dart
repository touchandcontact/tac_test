// ignore_for_file: use_build_context_synchronously

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pay_android/pay_android.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/models/subscription.dart';
import 'package:tac/services/account_service.dart';
import '../../components/generic_dialog.dart';
import '../../components/list_skeleton_loader.dart';
import '../../components/safearea_custom.dart';
import '../../constants.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/toast_helper.dart';
import '../../models/billing.dart';
import '../../models/card_and_shipping_for_pay.dart';
import '../../models/payment_list_card.dart';
import '../../models/stripe_price_dto.dart';
import '../../models/stripe_product_dto.dart';
import '../../models/subscribe.dart';
import '../../models/user.dart';
import '../../services/stripe_service.dart';
import '../../themes/dark_theme_provider.dart';
import '../landing.dart';
import '../payment/payment.dart';

class PaymentMethod extends StatefulWidget {
  String subscriptionType;

  PaymentMethod({super.key, required this.subscriptionType});

  @override
  PaymentMethodState createState() => PaymentMethodState();
}

class PaymentMethodState extends State<PaymentMethod> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  late Future<void> _futureAbbonamento;
  late Future<void> _futureCardScelta;
  ValueNotifier<PaymentListCard> preferCard = ValueNotifier(PaymentListCard());
  final ValueNotifier<BillingAddress> _preferBillingAddress =
      ValueNotifier(BillingAddress());
  ValueNotifier<bool> isSelected = ValueNotifier(false);
  final List<CustomPriceObj> _listObj = [];
  String locale = "it";

  static const Set<String> _kIds = <String>{
    "tac2_premium_year",
    "tac2_premium_month",
    "tac2_plus__year",
    "tac2_plus_month"
  };
  List<ProductDetails> products = [];

  generateTextStyle(String value, Color color,
          {double fontSize = 50, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        textAlign: TextAlign.left,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  chooseCard(CardShip? value) {
    preferCard.value = value?.paymentListCard ?? PaymentListCard();
  }

  chooseBillingAddress(BillingAddress? billingAddress) {
    _preferBillingAddress.value = billingAddress ?? BillingAddress();
  }

  _emptyResult() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
      child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Payment(
                          initialCard: preferCard.value,
                          user: user,
                          refreshChooseCard: (PaymentListCard? obj) {
                            preferCard.value = obj ?? PaymentListCard();
                          },
                          refreshChooseBillingAddress: (BillingAddress? obj) {
                            _preferBillingAddress.value =
                                obj ?? BillingAddress();
                          },
                          initialBillingAddress: _preferBillingAddress.value,
                        )));
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

  Future<void> loadData() async {
    try {
      List<StripeProductDto> productList = await loadProductByName();
      if (productList.isNotEmpty) {
        List<StripePriceDto> priceList =
            await loadPriceByName(productList[0].id!);
        if (priceList.isNotEmpty) {
          for (var element in priceList) {
            _listObj.add(CustomPriceObj(isSelected: false, priceList: element));
          }
        }
      }
    } catch (e) {
      throw Exception();
    }
  }

  updateCardChoose(PaymentListCard cardChoose) {
    preferCard.value = cardChoose;
  }

  Future<void> loadDataCard() async {
    try {
      if (user.stripeId != null) {
        await getListCard(user.stripeId!, hideAppleGooglePay: true)
            .then((value) {
          if (value.isNotEmpty) {
            preferCard.value = value[0];
          }
        });
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<StripeProductDto>> loadProductByName() async {
    return getProductByName(widget.subscriptionType);
  }

  Future<List<StripePriceDto>> loadPriceByName(String idProduct) async {
    return getProductPrices(idProduct);
  }

  Widget _cardSubscription(dynamic subItem) {
    return GestureDetector(
        onTap: () {
          for (var item in _listObj) {
            item.isSelected = false;
          }
          subItem.isSelected = true;
          isSelected.value = true;
          setState(() {});
        },
        child: subItem.isSelected
            ? CustomPaint(
                painter: SquareWithIcon(color),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    trailing: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color!,
                                width: 1)),
                        child: const Icon(Icons.check, color: Colors.white)),
                    title: RichText(
                        text: TextSpan(
                      text: locale != "it"
                          ? "${(subItem.priceList.unitAmountDecimal / 100).toStringAsFixed(2)}€"
                          : "${(subItem.priceList.unitAmountDecimal / 100).toStringAsFixed(2).replaceAll(".", ",")}€",
                      style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headline1!.color),
                      children: <TextSpan>[
                        TextSpan(
                            text: getInterval(subItem.priceList.interval),
                            style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    )),
                    subtitle: generateTextStyle(
                        subItem.priceList.interval == "month"
                            ? AppLocalizations.of(context)!.payMonth
                            : AppLocalizations.of(context)!.payYearly,
                        Colors.grey,
                        fontSize: 12),
                  ),
                ))
            : Container(
                margin: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  Theme.of(context).textTheme.headline1!.color!,
                              width: 1))),
                  title: RichText(
                      text: TextSpan(
                    text: locale != "it"
                        ? "${(subItem.priceList.unitAmountDecimal / 100).toStringAsFixed(2)}€"
                        : "${(subItem.priceList.unitAmountDecimal / 100).toStringAsFixed(2).replaceAll(".", ",")}€",
                    style: GoogleFonts.montserrat(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color),
                    children: <TextSpan>[
                      TextSpan(
                          text: getInterval(subItem.priceList.interval),
                          style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ],
                  )),
                  subtitle: generateTextStyle(
                      subItem.priceList.interval == "month"
                          ? AppLocalizations.of(context)!.payMonth
                          : AppLocalizations.of(context)!.payYearly,
                      Colors.grey,
                      fontSize: 12),
                ),
              ));
  }

  @override
  void initState() {
    initInAppPurchase();

    user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
    _futureAbbonamento = loadData();
    _futureCardScelta = loadDataCard();
    Future.delayed(Duration.zero, () {
      DarkThemeProvider themeChangeProvider =
          Provider.of<DarkThemeProvider>(context, listen: false);

      setState(() {
        locale = themeChangeProvider.locale.languageCode;
      });
    });
    super.initState();
  }

  void handleError() {
    Navigator.pop(context);
    failure(null);
  }

  Future<void> initInAppPurchase() async {
    if (Platform.isIOS && await InAppPurchase.instance.isAvailable()) {
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        handleError();
      } else {
        setState(() {
          products = response.productDetails;
        });

        _subscription =
            InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
          purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
            if (purchaseDetails.status == PurchaseStatus.error) {
              handleError();
            } else if (purchaseDetails.status == PurchaseStatus.canceled) {
              Navigator.pop(context);
            } else if (purchaseDetails.status == PurchaseStatus.purchased) {
              await completeInAppPurchase(purchaseDetails.purchaseID);
            }

            if (purchaseDetails.pendingCompletePurchase) {
              InAppPurchase.instance.completePurchase(purchaseDetails);
            }
          });
        }, onError: (error) {
          handleError();
        });
      }
    }
  }

  Future<void> completeInAppPurchase(String? transactionId) async {
    CustomPriceObj price =
        _listObj.firstWhere((element) => element.isSelected == true);
    Subscribe subscribe = Subscribe(
        paymentMethd: null,
        currency: "EUR",
        customer: user.stripeId,
        price: price.priceList.id,
        transactionId: transactionId);
    var value = await saveSubscription(subscribe, _preferBillingAddress.value.id == null ? null : _preferBillingAddress.value);
    await success(value);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String getInterval(String value) {
    String label = "";
    switch (value) {
      case "month":
        label = " / ${AppLocalizations.of(context)!.payInMonthly}";
        break;
      default:
        label = " / ${AppLocalizations.of(context)!.payInYearly}";
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaCustom(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(AppLocalizations.of(context)!.selectPlane,
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
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.infoProfile,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .color)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Payment(
                                              refreshChooseBillingAddress:
                                                  (BillingAddress? obj) {
                                                _preferBillingAddress.value =
                                                    obj ?? BillingAddress();
                                              },
                                              initialBillingAddress:
                                                  _preferBillingAddress.value,
                                              initialCard: preferCard.value,
                                              user: user,
                                              refreshChooseCard:
                                                  (PaymentListCard? obj) {
                                                preferCard.value =
                                                    obj ?? PaymentListCard();
                                              })));
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.seeAll,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey)),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          FutureBuilder<void>(
                              future: _futureCardScelta,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListSkeletonLoader(
                                      margin:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0));
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
                                              '${valueNotifier.address},${valueNotifier.city} (${valueNotifier.province})',
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
                            Text(AppLocalizations.of(context)!.selectYourPlane,
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
                            FutureBuilder<void>(
                                future: _futureAbbonamento,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ListSkeletonLoader(
                                        margin:
                                            EdgeInsets.fromLTRB(20, 20, 20, 0));
                                  }
                                  if (snapshot.hasError) {
                                    showErrorToast(
                                        AppLocalizations.of(context)!.error);
                                    return Text(
                                        AppLocalizations.of(context)!.error);
                                  }
                                  if (_listObj.isEmpty) {
                                    return _emptyResult();
                                  }
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _listObj.length,
                                      itemBuilder: (context, index) {
                                        return _cardSubscription(
                                            _listObj[index]);
                                      });
                                }),
                            Column(
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: isSelected,
                                  builder: (context, value, child) => value
                                      ? Platform.isAndroid
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 45,
                                              child: RawGooglePayButton(
                                                  type: GooglePayButtonType.pay,
                                                  onPressed: () async {
                                                    if (Platform.isIOS || await checkBillingAddress()) {
                                                      if (isValidGooglePayment()) {
                                                        await makePayment();
                                                      }
                                                    }
                                                  }))
                                          : const SizedBox(height: 0)
                                      : Container(),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: color,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ),
                                          side: const BorderSide(
                                              width: 0,
                                              color: Colors.transparent),
                                        ),
                                        onPressed: payWithCard,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 22, 8, 22),
                                          child: Text(
                                              AppLocalizations.of(context)!.pay,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      color.computeLuminance() >
                                                              0.5
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
                              ],
                            )
                          ],
                        )),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Future payWithCard() async {
    if (isValidGooglePayment()) {
      if (Platform.isIOS || await checkBillingAddress()) {
        await pay();
      }
    }
  }

  isValidGooglePayment() {
    if (!(_listObj.indexWhere((element) => element.isSelected == true) >= 0)) {
      showErrorToast(AppLocalizations.of(context)!.selectOneSubscription);
      return false;
    }
    return true;
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
          padding: const EdgeInsets.only(left: 40.0, right: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              tipo == "err"
                  ? AppLocalizations.of(context)!.ops
                  : AppLocalizations.of(context)!.paySuccess,
              style: GoogleFonts.montserrat(
                  fontSize: tipo == "err" ? 30 : 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headline1!.color),
            ),
            const SizedBox(height: 5),
            generateTextStyle(
                tipo == "err"
                    ? "${AppLocalizations.of(context)!.payError},"
                        "\n                ${AppLocalizations.of(context)!.tryLater}"
                    : "",
                Colors.grey,
                fontSize: 12)
          ])),
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

  Future<void> pay() async {
    CustomPriceObj? price =
        _listObj.indexWhere((element) => element.isSelected == true) >= 0
            ? _listObj.firstWhere((element) => element.isSelected == true)
            : null;
    if (Platform.isIOS) {
      try {
        showLoadingDialog(context);
        ProductDetails product;
        if (widget.subscriptionType.toLowerCase() == 'plus') {
          if (price!.priceList.interval == 'year') {
            product = products
                .firstWhere((element) => element.id == "tac2_plus__year");
          } else {
            product = products
                .firstWhere((element) => element.id == "tac2_plus_month");
          }
        } else {
          if (price!.priceList.interval == 'year') {
            product = products
                .firstWhere((element) => element.id == "tac2_premium_year");
          } else {
            product = products
                .firstWhere((element) => element.id == "tac2_premium_month");
          }
        }
        await InAppPurchase.instance.buyNonConsumable(
            purchaseParam: PurchaseParam(productDetails: product));
      } catch (e) {
        handleError();
      }
    } else {
      if (price?.priceList != null) {
        Subscribe subscribe = Subscribe(
          paymentMethd: preferCard.value.id,
          currency: "EUR",
          customer: user.stripeId,
          price: price?.priceList.id,
        );
        await displayPaymentSheet(subscribe);
      }
    }
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
                          builder: (context) => Payment(
                              refreshChooseBillingAddress:
                                  (BillingAddress? obj) {
                                _preferBillingAddress.value =
                                    obj ?? BillingAddress();
                              },
                              initialBillingAddress:
                                  _preferBillingAddress.value,
                              initialCard: preferCard.value,
                              user: user,
                              refreshChooseCard: (PaymentListCard? obj) {
                                preferCard.value = obj ?? PaymentListCard();
                              })));
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

  Future<void> makePayment() async {
    try {
      CustomPriceObj price =
          _listObj.firstWhere((element) => element.isSelected == true);
      if (Platform.isAndroid) {
        const stripe.GooglePayShippingAddressConfig();
        var gPay = stripe.GooglePayParams(
            allowCreditCards: true,
            merchantCountryCode: "IT",
            currencyCode: price.priceList.currency ?? "eur",
            merchantName:
                "${widget.subscriptionType} /${price.priceList.interval}",
            testEnv: Constants.isTestEnv);

        await stripe.Stripe.instance
            .createPlatformPayPaymentMethod(
          params: stripe.PlatformPayPaymentMethodParams.googlePay(
              googlePayParams: gPay,
              googlePayPaymentMethodParams:
                  stripe.GooglePayPaymentMethodParams(amount: price.priceList.unitAmountDecimal.toInt())),
        )
            .then((value) async {
          Subscribe subscribe = Subscribe(
            paymentMethd: value.id,
            currency: "EUR",
            customer: user.stripeId,
            price: price.priceList.id,
          );
          await displayPaymentSheet(subscribe);
        });
      } else {
        List<stripe.ApplePayCartSummaryItem> appleItem = [
          stripe.ApplePayCartSummaryItem.immediate(
              label: "${widget.subscriptionType} /${price.priceList.interval}",
              amount: (price.priceList.unitAmountDecimal / 100).toString())
        ];
        var appPay = stripe.ApplePayParams(
          cartItems: appleItem,
          currencyCode: price.priceList.currency ?? "eur",
          merchantCountryCode: "IT",
        );
        await stripe.Stripe.instance
            .createPlatformPayPaymentMethod(
                params: stripe.PlatformPayPaymentMethodParams.applePay(
                    applePayParams: appPay))
            .then((value) async {
          Subscribe subscribe = Subscribe(
            paymentMethd: value.id,
            currency: "EUR",
            customer: user.stripeId,
            price: price.priceList.id,
          );
          await displayPaymentSheet(subscribe);
        });
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      showErrorToast(AppLocalizations.of(context)!.genericError);
    }
  }

  displayPaymentSheet(Subscribe subscribe) async {
    showLoadingDialog(context);
    try {
      await saveSubscription(subscribe, _preferBillingAddress.value)
          .then((value) async {
        switch (value.intentStatus) {
          case "requires_action":
            await confirmPayment3DSecure(
                value.intentSecret!, subscribe.paymentMethd, value);
            break;
          case "succeeded":
            await success(value);
            break;
          default:
            if (value.invoiceStatus == "paid") {
              await success(value);
            } else {
              Navigator.pop(context);
              failure(value);
            }
            break;
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  failure(Subscription? subs) async {
    showDialog(
        context: context,
        builder: (_) => GenericDialog(
            vertical: Platform.isAndroid
                ? 110
                : (MediaQuery.of(context).size.height > 845 ? 200 : 180),
            child: dialog("err")));
  }

  success(Subscription subs) async {
    try {
      await getUserForEdit(user.identifier).then((userCall) async {
        if (userCall.userDTO.stripeSubscription != null) {
          await updateSubscription(
                  user.tacUserId,
                  widget.subscriptionType == "Plus"
                      ? 1
                      : widget.subscriptionType == "Premium"
                          ? 2
                          : 0)
              .then((value) async {
            await getUserForEdit(user.identifier).then((value) async {
              if (user.stripeSubscription == null) {
                if (value.userDTO.subscriptionType != null) {
                  await Hive.box("settings")
                      .put("user", jsonEncode(value.userDTO.toJson()));
                } else {
                  if (kDebugMode) {
                    print(
                        "user:${user.toJson()} \n value: ${value.userDTO.toJson()}");
                  }
                }
              }
            }).then((value) {
              Navigator.pop(context);
              showDialog(
                      context: context,
                      builder: (_) => GenericDialog(
                          vertical: Platform.isAndroid
                              ? 110
                              : (MediaQuery.of(context).size.height > 845
                                  ? 200
                                  : 180),
                          child: dialog("success")))
                  .then((value) => Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Landing()),
                        ModalRoute.withName('/'),
                      ));
            });
          });
        } else {
          Navigator.pop(context);
          await Hive.box("settings")
              .put("user", jsonEncode(userCall.userDTO.toJson()));
        }
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => GenericDialog(
              vertical: Platform.isAndroid
                  ? 110
                  : (MediaQuery.of(context).size.height > 845 ? 200 : 180),
              child: dialog("err")));
    }
  }

  Future confirmPayment3DSecure(
      String clientSecret, String? paymentMethodId, Subscription subs) async {
    try {
      await stripe.Stripe.instance
          .handleNextAction(clientSecret, returnURL: subs.intentRedirectUrl)
          .then((value) async {
        switch (value.status.name) {
          case "Succeeded":
            await success(subs);
            break;
          default:
            failure(subs);
            break;
        }
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => GenericDialog(
              vertical: Platform.isAndroid
                  ? 110
                  : (MediaQuery.of(context).size.height > 845 ? 200 : 180),
              child: dialog("err")));
    }
    return Future.value;
  }
}

class CustomPriceObj {
  bool isSelected;
  StripePriceDto priceList;

  CustomPriceObj({required this.isSelected, required this.priceList});
}

class SquareWithIcon extends CustomPainter {
  final Color color;

  SquareWithIcon(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    Path path = Path();
    path.moveTo(size.width - 50, 0);
    path.lineTo(size.width - 30, 0);
    path.conicTo(size.width, 0, size.width, 50, 1.9);
    path.close();
    canvas.drawPath(path, paint);

    const icon = Icons.star;
    TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.rtl);
    textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: 16.0, color: Colors.white, fontFamily: icon.fontFamily));
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 24, 8));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
