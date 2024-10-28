import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tac/components/payments/card_payments_widget.dart';
import 'package:tac/models/card_model.dart';
import 'package:tac/models/payment_list_card.dart';
import '../../components/buttons/loading_button.dart';
import '../../components/inputs/input_text.dart';
import '../../components/payments/billing_address_widget.dart';
import '../../components/safearea_custom.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/toast_helper.dart';
import '../../models/billing.dart';
import '../../models/user.dart';
import '../../services/account_service.dart';
import '../../services/billing_service.dart';
import '../../services/stripe_service.dart';
import 'address_billing_screen.dart';

class MySubscriptionPayment extends StatefulWidget {
  User user;
  PaymentListCard initialCard;
  BillingAddress initialBillingAddress;

  MySubscriptionPayment({
    Key? key,
    required this.user,
    required this.initialCard,
    required this.initialBillingAddress,
  }) : super(key: key);

  @override
  _MySubscriptionPaymentState createState() => _MySubscriptionPaymentState();
}

class _MySubscriptionPaymentState extends State<MySubscriptionPayment> with SingleTickerProviderStateMixin {
  stripe.CardFieldInputDetails _card =
  const stripe.CardFieldInputDetails(complete: false);
  bool isDarkMode = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  //Fatturazione
  final formKey = GlobalKey<FormState>();
  final formKeyTitolare = GlobalKey<FormState>();
  late Future<List<BillingAddress>> listBillingAddressFuture;
  late Future<List<PaymentListCard>> paymentListCardFuture;

  //Pagamento-Carte
  final CardModel _paymentCard = CardModel();
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  //Per tenere traccia dell'indirizzo e della carta scelti
  PaymentListCard? _cardChoose;
  BillingAddress? _billingAddressChoose;

  //Tiene traccia nel caso di eliminazioni carte o indirizzi
  bool _isMod = false;
  bool _isDelete = false;


  String currentIdCard = "";
  int currentIdAddress = 0;

  @override
  void initState() {
    if (widget.initialCard.id != null) {
      _cardChoose = widget.initialCard.clone();
      currentIdCard = widget.initialCard.id!;
    }
    if (widget.initialBillingAddress.id != null) {
      _billingAddressChoose = widget.initialBillingAddress.clone();
      currentIdAddress = widget.initialBillingAddress.id!;
    }
    listBillingAddressFuture = loadBillingList();
    paymentListCardFuture = loadPaymentsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await returnAndRefreshPage();
        return Future.value(true);
      },
      child: SafeAreaCustom(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(AppLocalizations.of(context)!.modifyCard,
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
                    onPressed: () async {
                      await returnAndRefreshPage();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _generateTextWidget(
                        AppLocalizations.of(context)!.listAddress,
                        Theme.of(context).textTheme.headline1!.color!,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),

                ///lista indirizzi fatturazione
                FutureBuilder<List<BillingAddress>>(
                    future: listBillingAddressFuture,
                    builder: (context,
                        AsyncSnapshot<List<BillingAddress>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 60,
                          child: SkeletonListView(
                            itemCount: 3,
                            item: SkeletonListTile(
                              verticalSpacing: 12,
                              titleStyle: SkeletonLineStyle(
                                  height: 20,
                                  minLength: 200,
                                  randomLength: false,
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Text(AppLocalizations.of(context)!.error)
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return _emptyResult(
                              AppLocalizations.of(context)!
                                  .addShippingBillingAddress,
                              "address");
                        } else {
                          return listAddress(snapshot.data!);
                        }
                      }
                      return Container();
                    }),
                if(!Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _generateTextWidget(
                        AppLocalizations.of(context)!.cardList,
                        Theme.of(context).textTheme.headline1!.color!,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),

                ///lista carte
                if(!Platform.isIOS)
                FutureBuilder<List<PaymentListCard>>(
                    future: paymentListCardFuture,
                    builder: (context,
                        AsyncSnapshot<List<PaymentListCard>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 60,
                          child: SkeletonListView(
                            itemCount: 3,
                            item: SkeletonListTile(
                              verticalSpacing: 12,
                              titleStyle: SkeletonLineStyle(
                                  height: 20,
                                  minLength: 200,
                                  randomLength: false,
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 16,
                            ),
                            Text(AppLocalizations.of(context)!.error)
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        return snapshot.data!.where((element) => element.card?.wallet?.type!="google_pay" && element.card?.wallet?.type!="apple_pay").toList().isEmpty
                            ? _emptyResult(
                            AppLocalizations.of(context)!.addPaymentMethod,
                            "carte")
                            : Column(
                          children: [
                            listCard(snapshot.data!),
                            _emptyResult(
                                AppLocalizations.of(context)!
                                    .addPaymentMethod,
                                "carte")
                          ],
                        );
                      }
                      return Container();
                    }),
                if(!Platform.isIOS)
                const SizedBox(height: 20,),
                ///bottone per salvare la nuova carta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
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
                          onPressed: () async {
                            if(Platform.isIOS){
                              if(await checkBillingAddress()){
                                if (!mounted) return;

                                Navigator.pop(context);
                                showSuccessToast(AppLocalizations.of(context)!.operationComplete);
                                Navigator.pop(context, [true, false]);
                              }
                              else{
                                showErrorToast(AppLocalizations.of(context)!.cardBillingError);
                              }
                            }
                            else{
                              if((_cardChoose != null && _cardChoose?.id != null && _cardChoose?.id != 0) && (_cardChoose?.card?.wallet == null || _cardChoose?.card?.wallet?.type == "card")  && await checkBillingAddress()){
                                await _updateSubscription();
                              }else{
                                showErrorToast(AppLocalizations.of(context)!.cardBillingError);
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
                            child: Text(AppLocalizations.of(context)!.select,
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
                ),
              ]),
            )),
      ),
    );
  }

  returnAndRefreshPage() async {
    showLoadingDialog(context);
    if(_cardChoose != null && _cardChoose?.id != null &&  _cardChoose?.id != "" &&_cardChoose?.id != currentIdCard) {
      if(_billingAddressChoose != null && _billingAddressChoose?.id != 0 && _billingAddressChoose?.id != currentIdAddress){
        bool isAddressSave = await checkBillingAddress();
        if(isAddressSave){
          await updatePaymentCard(widget.user.tacUserId, _cardChoose!.id!);
          _isMod = true;
        }
      }else{
        await updatePaymentCard(widget.user.tacUserId, _cardChoose!.id!);
        _isMod = true;
      }
    }else if(_billingAddressChoose != null && _billingAddressChoose?.id != 0 && _billingAddressChoose?.id != currentIdAddress){
      await updateStripeBilling(widget.user.tacUserId, _billingAddressChoose!.id!);
      _isMod = true;
    }
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) Navigator.pop(context, [_isDelete, _isMod]);
  }

  Future<void> _updateSubscription() async {
    showLoadingDialog(context);
    try {
      await updatePaymentCard(widget.user.tacUserId, _cardChoose!.id!);
      if (!mounted) return;
      Navigator.pop(context);
      showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      Navigator.pop(context, [true, false]);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  Future checkBillingAddress() async {
    if (_billingAddressChoose == null || _billingAddressChoose?.id == null || _billingAddressChoose?.id == 0) {
      return false;
    }
    try {
      return await updateStripeBilling(widget.user.tacUserId,
          _billingAddressChoose!.id!);
    } catch (e) {
      return false;
    }
  }


  _generateTextWidget(String value, Color color,
      {double fontSize = 16, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  listAddress(List<BillingAddress> listBillingAddress) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listBillingAddress.length,
          itemBuilder: (context, index) {
            return _createListRowAddress(listBillingAddress[index]);
          },
        ),
        _emptyResult(AppLocalizations.of(context)!.addAddress, "address")
      ],
    );
  }

  listCard(List<PaymentListCard> paymentListCard) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paymentListCard.length,
      itemBuilder: (context, index) {
        return _createListRowCard(paymentListCard[index]);
      },
    );
  }

  Widget _createListRowAddress(BillingAddress billingAddress) {
    return BillingAddressWidget(
      billingAddress: billingAddress,
      isSelected: billingAddress.shipmentAddressId != null &&
          billingAddress.shipmentAddressId ==
              _billingAddressChoose?.shipmentAddressId
          ? true
          : false,
      tacUserId: widget.user.tacUserId,
      onClick: (BillingAddress obj) {
        _billingAddressChoose = obj;
        setState(() {});
      },
      refreshList: () {
        _isDelete = true;
        setState(() {
          listBillingAddressFuture = loadBillingList();
        });
      },
    );
  }

  Widget _createListRowCard(PaymentListCard? paymentCard) {
    return CardPaymentWidget(
      paymentCard: paymentCard!,
      isSelected: paymentCard.id == _cardChoose?.id ? true : false,
      tacUserId: widget.user.tacUserId,
      onClick: (PaymentListCard obj) {
        _cardChoose = obj;
        setState(() {});
      },
      refreshList: () {
        _isDelete = true;
        setState(() {
          paymentListCardFuture = loadPaymentsList();
        });
      },
    );
  }

  ///tasto per aggiunta per carte e fatturazione
  _emptyResult(String label, String onPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
      child: OutlinedButton(
          onPressed: () {
            if (onPressed == "carte") {
              showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              card(),
                              const SizedBox(
                                height: 20,
                              ),
                            ]),
                        Positioned(
                            bottom: -30,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .color),
                                child: const Center(
                                    child: Icon(Icons.close,
                                        size: 30, color: Colors.white)),
                              ),
                            ))
                      ],
                    ),
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddressBillingScreen(
                        tacUserId: widget.user.tacUserId,
                      ))).then((value) {
                if (value != null && value) {
                  setState(() {
                    listBillingAddressFuture = loadBillingList();
                  });
                }
              });
            }
          },
          style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(width: 1.0, color: color),
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(15), right: Radius.circular(15)))),
          child: SizedBox(
            height: 57,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                      onPressed != "carte"
                          ? Icons.note_alt_rounded
                          : Icons.credit_card,
                      color: color,
                      size: 20),
                  FittedBox(
                    fit: BoxFit.cover,
                    child: Text(
                      label,
                      style: GoogleFonts.montserrat(
                          color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.add, color: color, size: 20),
                ]),
          )),
    );
  }

  ///aggiunta carte e titolare
  Widget card() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Align(
                alignment: Alignment.center,
                child: _generateTextWidget(AppLocalizations.of(context)!.addCard,
                    Theme.of(context).textTheme.headline1!.color!,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Form(
              key: formKeyTitolare,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: InputText(
                    labelStyle: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.headline2!.color,
                        fontWeight: FontWeight.w500),
                    label: AppLocalizations.of(context)!.cardHolder,
                    onChange: (e) => _paymentCard?.fullName = e,
                    validator: (value) {
                      if (value == null || value == "") {
                        return AppLocalizations.of(context)!.requiredField;
                      }
                      return null;
                    }),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(AppLocalizations.of(context)!.cardDetail, style: GoogleFonts.montserrat(color: Theme.of(context).textTheme.headline1!.color, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            stripe.CardFormField(
              dangerouslyGetFullCardDetails: true,
              enablePostalCode: false,
              style: stripe.CardFormStyle(
                  fontSize: 16,
                  backgroundColor: isDarkMode ? Colors.black : Theme.of(context).secondaryHeaderColor,
                  textColor: Colors.black,
                  placeholderColor:
                  Theme.of(context).textTheme.headline2!.color,
                  borderRadius: 20),
              controller: stripe.CardFormEditController(),
              onCardChanged: (card) {
                _card = card!;
              },
            ),
            Center(child: LoadingButton(
                onPress: addCard,
                width: 180,
                text: AppLocalizations.of(context)!.addCard,
                textSize: 15,
                color: color,
                borderColor: color)),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  Future addCard() async {
    if (_card.complete && formKeyTitolare.currentState!.validate()) {
      _paymentCard.number = _card.number;
      _paymentCard.expMonth = _card.expiryMonth.toString();
      _paymentCard.expYear = _card.expiryYear.toString();
      _paymentCard.cvc = _card.cvc;

      var method = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                  billingDetails:
                  stripe.BillingDetails(name: _paymentCard.fullName))));

      return await attachPaymentMethod(method.id, widget.user.stripeId!)
          .then((value) {
        Navigator.pop(context);
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        setState(() {
          paymentListCardFuture = loadPaymentsList();
        });
      });
    } else {
      showErrorToast(AppLocalizations.of(context)!.dataCardNotCompleted);
    }
    return Future.value();
  }

  Future<List<PaymentListCard>> loadPaymentsList() async {
    return await getListCard(widget.user.stripeId!,hideAppleGooglePay: true);
  }

  Future<List<BillingAddress>> loadBillingList() async {
    return await getBilling(widget.user.tacUserId);
  }
}
