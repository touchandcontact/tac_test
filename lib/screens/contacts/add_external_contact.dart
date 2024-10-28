import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/components/profile_image_picker.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/external_contact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tac/models/external_contact_address.dart';
import 'package:tac/models/external_contact_elephone.dart';
import 'package:tac/services/contacts_services.dart';
import 'package:email_validator/email_validator.dart';

import '../../extentions/hexcolor.dart';
import '../../models/user.dart';

class AddExternalContactModal extends StatefulWidget {
  const AddExternalContactModal({
    super.key,
    this.contactParam,
    required this.onSuccess,
  });

  final ExternalContact? contactParam;
  final void Function() onSuccess;

  @override
  AddExternalContactModalState createState() => AddExternalContactModalState();
}

class AddExternalContactModalState extends State<AddExternalContactModal> {
  @override
  AddExternalContactModal get widget => super.widget;

  @override
  void initState() {
    contact =
        widget.contactParam == null ? ExternalContact() : widget.contactParam!;
    super.initState();
  }

  final formKey = GlobalKey<FormState>();

  String notes = "";
  File? pickedImage;
  ExternalContact contact = ExternalContact();
  List<ExternalContactAddress> addresses = <ExternalContactAddress>[];
  List<ExternalContactTelephone> telephones = <ExternalContactTelephone>[];

  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  Future save(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      showLoadingDialog(context);
      try {
        contact.creationDate = DateTime.now();
        await insertExternalContact(user.tacUserId, notes, contact, pickedImage,
            null, addresses, telephones);
        showSuccessToast(AppLocalizations.of(context)!.newContactSuccess);

        widget.onSuccess();
        Future.microtask(() => Navigator.pop(context));
        Future.microtask(() => Navigator.pop(context));
      } on Exception catch (_) {
        showErrorToast(AppLocalizations.of(context)!.error);
        Future.microtask(() => Navigator.pop(context));
      }
    }
  }

  void onPickerComplete(File file) {
    setState(() {
      pickedImage = file;
    });
  }

  void addTelephone() {
    telephones = [...telephones, ExternalContactTelephone()];
    setState(() {
      telephones = List.from(telephones);
    });
  }

  void removeTelephone(ExternalContactTelephone item) {
    telephones.remove(item);
    setState(() {
      telephones = List.from(telephones);
    });
  }

  void addAddress() {
    addresses = [...addresses, ExternalContactAddress()];
    setState(() {
      addresses = List.from(addresses);
    });
  }

  void removeAddress(ExternalContactAddress item) {
    addresses.remove(item);
    setState(() {
      addresses = List.from(addresses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            flexibleSpace: Center(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close)),
                        const Spacer(),
                        Text( widget.contactParam == null ? AppLocalizations.of(context)!.addContact : AppLocalizations.of(context)!.modContactLabel,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.headline1),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => save(context),
                          child: Text(AppLocalizations.of(context)!.save,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        )
                      ],
                    )))),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Center(
                          child: ProfileImagePicker(
                              onPickComplete: onPickerComplete)),
                      Divider(
                          height: 40, color: Theme.of(context).backgroundColor),
                      Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Form(
                              key: formKey,
                              child: Column(children: [
                                InputText(
                                    label: AppLocalizations.of(context)!.relativeNote,
                                    outsideLabel: true,
                                    maxLines: 4,
                                    onChange: (e) => setState(() {
                                          notes = e;
                                        })),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                                Row(children: [
                                  Text(AppLocalizations.of(context)!.infoProfile,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline1!
                                              .color,
                                          fontWeight: FontWeight.w600))
                                ]),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.name,
                                    initalValue: contact.name,
                                    textCapitalization: TextCapitalization.words,
                                    onChange: (e) => setState(() {
                                          contact.name = e;
                                        }),
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }

                                      return null;
                                    }),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.surname,
                                    initalValue: contact.surname,
                                    textCapitalization: TextCapitalization.words,
                                    onChange: (e) => setState(() {
                                          contact.surname = e;
                                        }),
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }
                                      return null;
                                    }),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.email,
                                    keyboardType: TextInputType.emailAddress,
                                    initalValue: contact.email,
                                    onChange: (e) => setState(() {
                                          contact.email = e;
                                        }),
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }
                                      if (!EmailValidator.validate(value)) {
                                        return AppLocalizations.of(context)!
                                            .insertValidEmail;
                                      }

                                      return null;
                                    }),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 20, 0)),
                                Row(children: [
                                  Text(AppLocalizations.of(context)!.additionalInfo,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline1!
                                              .color,
                                          fontWeight: FontWeight.w600))
                                ]),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.profession,
                                    initalValue: contact.profession,
                                    onChange: (e) => setState(() {
                                          contact.profession = e;
                                        })),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.company,
                                    initalValue: contact.company,
                                    onChange: (e) => setState(() {
                                          contact.company = e;
                                        })),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                Stack(
                                  children: [
                                    InputText(
                                        label: AppLocalizations.of(context)!.telephone,
                                        keyboardType: TextInputType.phone,
                                        initalValue: contact.telephone,
                                        onChange: (e) => setState(() {
                                              contact.telephone = e;
                                            })),
                                    Positioned(
                                        right: 5,
                                        child: TextButton(
                                            onPressed: addTelephone,
                                            child: Text(AppLocalizations.of(context)!.add,
                                                style: GoogleFonts.montserrat(
                                                    color: color,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600))))
                                  ],
                                ),
                                getTelephones(context),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                Stack(
                                  children: [
                                    InputText(
                                        label: AppLocalizations.of(context)!.address,
                                        initalValue: contact.address,
                                        onChange: (e) => setState(() {
                                              contact.address = e;
                                            })),
                                    Positioned(
                                        right: 5,
                                        child: TextButton(
                                            onPressed: addAddress,
                                            child: Text(AppLocalizations.of(context)!.add,
                                                style: GoogleFonts.montserrat(
                                                    color: color,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600))))
                                  ],
                                ),
                                getAddresses(context),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.website,
                                    initalValue: contact.website,
                                    keyboardType: TextInputType.url,
                                    onChange: (e) => setState(() {
                                          contact.website = e;
                                        })),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                                InputText(
                                    label: AppLocalizations.of(context)!.p_iva,
                                    initalValue: contact.vat,
                                    onChange: (e) => setState(() {
                                          contact.vat = e;
                                        }))
                              ])))
                    ]))));
  }

  Widget getAddresses(BuildContext context) {
    if (addresses.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: addresses
            .asMap()
            .entries
            .map((entry) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Stack(children: [
                  InputText(
                      label: "${AppLocalizations.of(context)!.address} ${entry.key + 2}",
                      onChange: (e) => setState(() {
                            entry.value.address = e;
                          })),
                  Positioned(
                      right: 5,
                      child: IconButton(
                          onPressed: () => removeAddress(entry.value),
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).textTheme.headline2!.color,
                          )))
                ])))
            .toList());
  }

  Widget getTelephones(BuildContext context) {
    if (telephones.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: telephones
            .asMap()
            .entries
            .map((entry) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Stack(children: [
                  InputText(
                      keyboardType: TextInputType.phone,
                      label: "${AppLocalizations.of(context)!.telephone} ${entry.key + 2}",
                      onChange: (e) => setState(() {
                            entry.value.telephone = e;
                          })),
                  Positioned(
                      right: 5,
                      child: IconButton(
                          onPressed: () => removeTelephone(entry.value),
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).textTheme.headline2!.color,
                          )))
                ])))
            .toList());
  }
}
