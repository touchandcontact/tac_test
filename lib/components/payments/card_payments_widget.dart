import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../dialogs.dart';
import '../../helpers/toast_helper.dart';
import '../../models/payment_list_card.dart';
import '../../services/stripe_service.dart';
import '../buttons/outlinet_loading_button.dart';
import '../generic_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardPaymentWidget extends StatefulWidget {
  PaymentListCard paymentCard;
  int tacUserId;
  bool isSelected;
  VoidCallback refreshList;
  Function(PaymentListCard) onClick;
  CardPaymentWidget({Key? key,this.isSelected = false, required this.onClick,required this.paymentCard,required this.tacUserId, required this.refreshList}) : super(key: key);

  @override
  State<CardPaymentWidget> createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends State<CardPaymentWidget> {

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        Container(
          margin:
          const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          alignment: Alignment.center,
          height: 80,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme
                .of(context)
                .primaryColor
                : Colors.white,
            border: Border.all(
                color: widget.isSelected
                    ? Theme
                    .of(context)
                    .primaryColor
                    : Colors.grey,
                width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading:   GestureDetector(
              onTap: () {
                if(!widget.isSelected){
                  showDeleteDialog();
                  return;
                }
                showDialog(
                    context: context,
                    builder: (context) {
                      return GenericDialog(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text( AppLocalizations.of(context)!.attention,
                                      style: GoogleFonts.montserrat(fontSize: 24,fontWeight: FontWeight.w600)),
                                  Text( AppLocalizations.of(context)!.errorSelectionDelete,
                                      style: GoogleFonts.montserrat(fontSize: 16)),
                                ],
                              )));
                    });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Icon(Icons.delete,
                    color: Colors.white),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onClick(widget.paymentCard);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: widget.isSelected
                                    ? Theme
                                    .of(context)
                                    .primaryColor
                                    : Theme
                                    .of(context)
                                    .textTheme
                                    .headline1!
                                    .color!,
                                width: 1)),
                        child: Icon(Icons.check,
                            color: widget.isSelected
                                ? Theme
                                .of(context)
                                .primaryColor
                                : Colors.white)),
                  ),
                ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.paymentCard.card!.brand! == "mastercard"
                    ? const FaIcon(
                  FontAwesomeIcons.ccMastercard,
                  size: 45,
                )
                    : widget.paymentCard.card!.brand! == "visa"
                    ? const FaIcon(
                  FontAwesomeIcons.ccVisa,
                  size: 45,
                )
                    : widget.paymentCard.card!.brand! == "american express"
                    ? const FaIcon(
                  FontAwesomeIcons.ccAmex,
                  size: 45,
                )
                    : const SizedBox(),
                const SizedBox(width: 4),
                RichText(
                    text: TextSpan(
                      text: " **********${widget.paymentCard.card?.last4}",
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected
                              ? Colors.white
                              : Theme
                              .of(context)
                              .textTheme
                              .headline2!
                              .color),
                    )),
              ],
            ),
          ),
        ),
      ],
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
              disableExit: false,
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
                child: Text("${AppLocalizations.of(context)!.deleteCard}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text("${AppLocalizations.of(context)!.deleteCardProceed}?",
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
                  onPress: () => deleteAddress(),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                ))
          ],
        ));
  }

  Future deleteAddress() async {
    try {
      await deleteCardElement(widget.paymentCard.id!)
          .then((value) {
        Navigator.pop(context);
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        widget.refreshList();
      });
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }
}
