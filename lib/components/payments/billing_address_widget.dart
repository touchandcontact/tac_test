import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tac/screens/payment/address_billing_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../dialogs.dart';
import '../../helpers/toast_helper.dart';
import '../../models/billing.dart';
import '../../services/billing_service.dart';
import '../buttons/outlinet_loading_button.dart';
import '../generic_dialog.dart';

class BillingAddressWidget extends StatefulWidget {
  BillingAddress billingAddress;
  int tacUserId;
  bool isSelected;
  VoidCallback refreshList;
  Function(BillingAddress) onClick;

  BillingAddressWidget(
      {Key? key,
      this.isSelected = false,
      required this.onClick,
      required this.billingAddress,
      required this.tacUserId,
      required this.refreshList})
      : super(key: key);

  @override
  State<BillingAddressWidget> createState() => _BillingAddressWidgetState();
}

class _BillingAddressWidgetState extends State<BillingAddressWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
        alignment: Alignment.center,
        height: 100,
        decoration: BoxDecoration(
          color:
              widget.isSelected ? Theme.of(context).primaryColor : Colors.white,
          border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: GestureDetector(
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
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddressBillingScreen(
                                tacUserId: widget.tacUserId,
                                billingAddress: widget.billingAddress,
                                isMod: true,
                              ))).then((value) {
                    if (value != null && value) {
                      widget.refreshList();
                    }
                  });
                },
                child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: widget.isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            width: 1)),
                    child: const Icon(Icons.edit, color: Colors.white)),
              ),
              GestureDetector(
                onTap: () {
                  widget.onClick(widget.billingAddress);
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
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color!,
                              width: 1)),
                      child: Icon(Icons.check,
                          color: widget.isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white)),
                ),
              ),
            ],
          ),
          title: widget.billingAddress.nominative == null
              ? Text(widget.billingAddress.address!,
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.headline2!.color))
              : RichText(
                  overflow: TextOverflow.clip,
                  text: TextSpan(
                    text: "${widget.billingAddress.nominative}\n",
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.headline2!.color),
                    children: <TextSpan>[
                      TextSpan(
                          text: widget.billingAddress.address,
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color)),
                    ],
                  )),
        ),
      ),
    ]);
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
                child: Text("${AppLocalizations.of(context)!.deleteAddress}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteBillingAddress}?",
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
      await deleteAddressElement(widget.billingAddress.shipmentAddress!.id!)
          .then((value) {
        Navigator.pop(context);
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        widget.refreshList();
      });
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }
}
