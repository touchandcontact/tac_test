// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/contacts/folders/folder_image_picker.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/folder_insert.dart';
import 'package:tac/screens/contacts/select_contacts.dart';
import 'package:tac/services/contacts_services.dart';

import '../../../components/contacts/shared_avatar.dart';
import '../../../extentions/hexcolor.dart';
import '../../../models/contact.dart';
import '../../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddFolderModal extends StatefulWidget {
  const AddFolderModal({super.key, required this.onSuccess});

  final Future Function() onSuccess;

  @override
  AddFolderModalState createState() => AddFolderModalState();
}

class AddFolderModalState extends State<AddFolderModal> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  FolderInsert folder = FolderInsert();

  List<Contact> toShare = <Contact>[];

  void onPickerComplete(File file) {
    String base64Image = base64Encode(file.readAsBytesSync());
    folder.image = base64Image;
  }

  void openSelectContactForShare(BuildContext context) {
    if (!folder.shared) return;

    FocusScope.of(context).unfocus();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectContacts(
                  onButtonPress: (p0) => onSharedSelect(context, p0),
                  title: AppLocalizations.of(context)!.addContacts,
                  subtitle: AppLocalizations.of(context)!.shareContactInFolder,
                  onlyTac: true,
                  buttonText: "Conferma",
                )));
  }

  void onSharedChange(bool value) {
    setState(() {
      folder.shared = value;
    });
  }

  void onHubspotChange(bool value) {
    setState(() {
      folder.addHubspot = value;
    });
  }

  void onSalesforceChange(bool value) {
    setState(() {
      folder.addSalesForce = value;
    });
  }

  Future onSharedSelect(BuildContext context, List<Contact> contacts) {
    setState(() {
      toShare = contacts;
    });
    Navigator.pop(context);

    return Future.value();
  }

  void goToSelectContacts(BuildContext context) {
    if (folder.name.isEmpty) {
      showErrorToast(AppLocalizations.of(context)!.insertName);
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectContacts(
                  onButtonPress: (p0) =>
                      createFolder(context, p0.map((e) => e.id).toList()),
                  title: AppLocalizations.of(context)!.newFolder,
                  subtitle: AppLocalizations.of(context)!.addContactInFolder,
                  onlyTac: false,
                  buttonText: AppLocalizations.of(context)!.createFolder,
                )));
  }

  Future createFolder(BuildContext context, List<int> contacts) async {
    try {
      folder.userid = user.tacUserId;
      await insertFolder(
          folder, contacts, toShare.map((e) => e.tacUserId!).toList());
      await widget.onSuccess();

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: Platform.isAndroid ? 24 : 70, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15))),
                          child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color,
                                size: 30,
                              ))),
                      Expanded(
                          flex: 9,
                          child: Text(AppLocalizations.of(context)!.newFolder,
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.headline1)),
                      const Expanded(flex: 3, child: SizedBox.shrink())
                    ]),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    Center(
                        child: FolderImagePicker(
                            onPickComplete: onPickerComplete)),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                        child: Text(
                            AppLocalizations.of(context)!.nameFolderToAdd,
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: InputText(
                            label: AppLocalizations.of(context)!.nameFolder,
                            onChange: ((p0) => setState(() {
                                  folder.name = p0;
                                })))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: InputText(
                            label:
                                AppLocalizations.of(context)!.folderDescription,
                            outsideLabel: true,
                            maxLines: 5,
                            onChange: ((p0) => setState(() {
                                  folder.description = p0;
                                })))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(children: [
                          Text(AppLocalizations.of(context)!.sharedFolder,
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color)),
                          const Spacer(),
                          Switch(
                              value: folder.shared, onChanged: onSharedChange)
                        ])),
                    if (user.company != null && user.company!.hasHubspot)
                      Row(children: [
                            Text(AppLocalizations.of(context)!.connectToHubspot,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const Spacer(),
                            Switch(
                                value: folder.addHubspot,
                                onChanged: onHubspotChange)
                          ]),
                    if (user.company != null && user.company!.hasSalesForce)
                       Row(children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .connectToSalesforce,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const Spacer(),
                            Switch(
                                value: folder.addSalesForce,
                                onChanged: onSalesforceChange)
                          ]),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: GestureDetector(
                            onTap: () => openSelectContactForShare(context),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .chooseFolder,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline2!
                                                    .color
                                                    ?.withOpacity(folder.shared
                                                        ? 1
                                                        : 0.6)))),
                                    const Spacer(),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 30,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .color
                                            ?.withOpacity(
                                                folder.shared ? 1 : 0.6))
                                  ]),
                                  if (toShare.isNotEmpty && folder.shared)
                                    Container(
                                        padding: const EdgeInsets.only(top: 10),
                                        height: 60,
                                        child: getSharedInfo())
                                ]))),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
                    Center(
                        child: TextButton(
                            onPressed: () => goToSelectContacts(context),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(60, 15, 60, 15)),
                              backgroundColor: MaterialStateProperty.all(color),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            ),
                            child: Text(AppLocalizations.of(context)!.forward,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: color.computeLuminance() > 5
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color
                                        : Colors.white))))
                  ],
                ))));
  }

  Widget getSharedInfo() {
    if (toShare.length == 1) {
      return SharedAvatar(item: toShare[0]);
    } else if (toShare.length == 2) {
      return Stack(children: [
        Positioned(left: 0, child: SharedAvatar(item: toShare[0])),
        Positioned(left: 30, child: SharedAvatar(item: toShare[1]))
      ]);
    } else if (toShare.length == 3) {
      return Stack(children: [
        Positioned(left: 0, child: SharedAvatar(item: toShare[0])),
        Positioned(left: 30, child: SharedAvatar(item: toShare[1])),
        Positioned(left: 60, child: SharedAvatar(item: toShare[2]))
      ]);
    } else {
      return Stack(children: [
        Positioned(left: 0, child: SharedAvatar(item: toShare[0])),
        Positioned(left: 30, child: SharedAvatar(item: toShare[1])),
        Positioned(left: 60, child: SharedAvatar(item: toShare[2])),
        Positioned(
            left: 120,
            top: 15,
            child: Text(
                "${AppLocalizations.of(context)!.plusSymbol} ${AppLocalizations.of(context)!.others} ${toShare.length - 3} ${AppLocalizations.of(context)!.participants}",
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headline2!.color)))
      ]);
    }
  }
}
