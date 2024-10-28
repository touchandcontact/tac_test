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

import '../../../extentions/hexcolor.dart';
import '../../../models/ocr_contact_dto.dart';
import '../../../models/user.dart';
import '../external_contact_detail.dart';

class OcrAddScreen extends StatefulWidget {
  const OcrAddScreen({
    super.key,
    required this.contactMod,
    required this.file,
  });

  final OcrContactDto contactMod;
  final File file;

  @override
  OcrAddScreenState createState() => OcrAddScreenState();
}

class OcrAddScreenState extends State<OcrAddScreen> {
  final formKey = GlobalKey<FormState>();

  String headerText = "";
  File? pickedImage;
  late OcrContactDto contact;
  ValueNotifier<List<ExternalContactAddress>> addressesNotifier =
  ValueNotifier<List<ExternalContactAddress>>([]);
  ValueNotifier<List<ExternalContactTelephone>> telephonesNotifier =
  ValueNotifier<List<ExternalContactTelephone>>([]);

  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  //CONTROLLER FOR ADDRESS
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    contact = OcrContactDto(id: 0);
    contact = widget.contactMod.clone();
    _addressController.text = contact.address ?? "";
    if (_addressController.text.isNotEmpty &&
        _addressController.text.length > 28) {
      _addressController.text =
      "${_addressController.text.substring(0, 28)}...";
    }
    _addressController.text = _addressController.text;
    addressesNotifier.value = contact.addresses ?? [];
    telephonesNotifier.value = contact.telephones ?? [];
    super.initState();
  }

  Future save(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final ExternalContact externalContact = ExternalContact()
        ..name = contact.name!
        ..surname = contact.surname!
        ..email = contact.email!
        ..profileImage = contact.profileImage
        ..company = contact.company
        ..profession = contact.profession
        ..website = contact.website
        ..address = contact.address
        ..telephone = contact.telephone
        ..vat = contact.vat
        ..creationDate = DateTime.now()
      ;
      showLoadingDialog(context);
      try {
        final response = await insertExternalContact(user.tacUserId, contact.notes ?? "", externalContact, pickedImage,
            widget.file, addressesNotifier.value, telephonesNotifier.value);
        showSuccessToast(AppLocalizations.of(context)!.modContactSuccess);
        if(!mounted) return;
        Hive.box("settings").put("reloadAfterAdd", externalContact.email);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExternalContactDetail(contactId: response)));
      } on Exception catch (_) {
        showErrorToast(AppLocalizations.of(context)!.error);
        Future.microtask(() => Navigator.pop(context));
      }
    }
  }

  void onPickerComplete(File file) {
    pickedImage = file;
  }

  void addTelephone() {
    telephonesNotifier.value = [...telephonesNotifier.value, ExternalContactTelephone()];
  }

  void removeTelephone(ExternalContactTelephone item) {
    telephonesNotifier.value.remove(item);
    telephonesNotifier.value = [...telephonesNotifier.value];
  }

  void addAddress() {
    addressesNotifier.value = [...addressesNotifier.value, ExternalContactAddress()];
  }

  void removeAddress(ExternalContactAddress item) {
    addressesNotifier.value.remove(item);
    addressesNotifier.value = [...addressesNotifier.value];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
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
                          Expanded(
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close)),
                          ),
                          Expanded(
                              flex: 9,
                              child: Text(headerText,
                                  textAlign: TextAlign.right,
                                  style:
                                  Theme.of(context).textTheme.headline1)),
                          Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => save(context),
                                child: Text(AppLocalizations.of(context)!.save,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        color: color,
                                        fontWeight: FontWeight.w600)),
                              ))
                        ],
                      )))),
          body: SingleChildScrollView(
              reverse: true,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                            child: ProfileImagePicker(initialImage: widget.contactMod.profileImage,
                                onPickComplete: onPickerComplete)),
                        Divider(
                            height: 40,
                            color: Theme.of(context).backgroundColor),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Form(
                              key: formKey,
                              child: Column(children: [
                                InputText(
                                    initalValue: contact.notes,
                                    label: AppLocalizations.of(context)!.relativeNote,
                                    outsideLabel: true,
                                    maxLines: 4,
                                    onChange: (e) => contact.notes = e),
                                const SizedBox(
                                  height: 30,
                                ),
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
                                const SizedBox(
                                  height: 10,
                                ),
                                InputText(
                                    label: AppLocalizations.of(context)!.name,
                                    initalValue: contact.name,
                                    textCapitalization: TextCapitalization.words,
                                    onChange: (e) => contact.name = e,
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }

                                      return null;
                                    }),
                                const SizedBox(height: 10),
                                InputText(
                                    label: AppLocalizations.of(context)!.surname,
                                    initalValue: contact.surname,
                                    textCapitalization: TextCapitalization.words,
                                    onChange: (e) => contact.surname = e,
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }
                                      return null;
                                    }),
                                const SizedBox(height: 10),
                                InputText(
                                    label: AppLocalizations.of(context)!.email,
                                    initalValue: contact.email,
                                    onChange: (e) => contact.email = e,
                                    validator: (value) {
                                      if (value == null || value == "") {
                                        return AppLocalizations.of(context)!
                                            .requiredField;
                                      }
                                      if (!validateEmail(value)) {
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
                                const SizedBox(height: 10),
                                InputText(
                                    label: AppLocalizations.of(context)!.profession,
                                    initalValue: contact.profession,
                                    onChange: (e) => contact.profession = e),
                                const SizedBox(height: 10),
                                InputText(
                                    label: AppLocalizations.of(context)!.company,
                                    initalValue: contact.company,
                                    onChange: (e) => contact.company = e),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    InputText(
                                        label: AppLocalizations.of(context)!.telephone,
                                        initalValue: contact.telephone,
                                        onChange: (e) => contact.telephone = e),
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
                                ValueListenableBuilder(valueListenable: telephonesNotifier, builder: (context, valueNotifier, child) => getTelephones(valueNotifier)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      _addressController.text =
                                          contact.address ?? "";
                                    } else {
                                      if (_addressController.text.length > 28) {
                                        _addressController.text =
                                            "${_addressController.text.substring(0, 28)}...";
                                      }
                                    }
                                  },
                                  child: InputText(
                                      suffixIcon: Padding(
                                        padding:
                                        const EdgeInsets.only(right: 5.0),
                                        child: TextButton(
                                            onPressed: addAddress,
                                            child: Text(AppLocalizations.of(context)!.add,
                                                style: GoogleFonts.montserrat(
                                                    color: color,
                                                    fontSize: 13,
                                                    fontWeight:
                                                    FontWeight.w600))),
                                      ),
                                      controller: _addressController,
                                      label: AppLocalizations.of(context)!.address,
                                      onChange: (e) => contact.address = e),
                                ),
                                ValueListenableBuilder(valueListenable: addressesNotifier, builder: (context, valueNotifier, child) => getAddresses(valueNotifier)),
                                const SizedBox(
                                  height: 10,
                                ),
                                InputText(
                                    label: AppLocalizations.of(context)!.website,
                                    keyboardType: TextInputType.url,
                                    initalValue: contact.website,
                                    onChange: (e) => contact.website = e),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // InputText(
                                //     label: AppLocalizations.of(context)!.p_iva,
                                //     initalValue: contact.vat,
                                //     onChange: (e) => contact.vat = e),
                              ])),
                        )
                      ])))),
    );
  }

  bool validateEmail(String value) {
    return  EmailValidator.validate(value);
  }

  Widget getAddresses(List<ExternalContactAddress> addressList) {
    if (addressList.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: addressList
            .asMap()
            .entries
            .map((entry) => Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Stack(children: [
              InputText(
                  label: "${AppLocalizations.of(context)!.address} ${entry.key + 2}",
                  initalValue: entry.value.address,
                  onChange: (e) => entry.value.address = e),
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

  Widget getTelephones(List<ExternalContactTelephone> telephoneList) {
    if (telephoneList.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: telephoneList
            .asMap()
            .entries
            .map((entry) => Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Stack(children: [
              InputText(
                  label: "${AppLocalizations.of(context)!.telephone} ${entry.key + 2}",
                  initalValue: entry.value.telephone,
                  onChange: (e) => entry.value.telephone = e),
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
