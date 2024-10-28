// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/contacts/folders/folder_image_picker.dart';
import 'package:tac/components/contacts/shared_avatar.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/contact.dart';
import 'package:tac/models/folder_insert.dart';
import 'package:tac/screens/contacts/select_contacts.dart';
import 'package:tac/services/contacts_services.dart';

import '../../../extentions/hexcolor.dart';
import '../../../models/user.dart';

class EditFolder extends StatefulWidget {
  const EditFolder({super.key, required this.id, required this.onSuccess});

  final int id;
  final Function onSuccess;

  @override
  EditFolderState createState() => EditFolderState();
}

class EditFolderState extends State<EditFolder> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  bool error = false;
  bool isLoading = false;

  FolderInsert folder = FolderInsert();
  List<Contact> toShare = <Contact>[];
  List<Contact> alreadyShared = <Contact>[];

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    loadFolder()
        .then((value) => loadSharedContacts().then((value) => setState(() {
              isLoading = false;
            })));

    super.initState();
  }

  Future loadFolder() async {
    try {
      var f = await getFolder(widget.id);
      setState(() {
        folder.userid = f.userId;
        folder.description = f.description;
        folder.image = f.image;
        folder.shared = f.shared;
        folder.name = f.name;
        folder.addHubspot = f.addHubspot;
        folder.addSalesForce = f.addSalesForce;
        folder.id = widget.id;
      });
    } catch (_) {
      setState(() {
        error = true;
        isLoading = false;
      });
    }
  }

  Future loadSharedContacts() async {
    if (folder.shared) {
      try {
        alreadyShared =
            await getFolderSharedContacts(user.tacUserId, widget.id);
        if (alreadyShared.isNotEmpty) {
          setState(() {
            toShare = List.from(alreadyShared);
          });
        }
      } catch (e) {
        setState(() {
          error = true;
          isLoading = false;
        });
      }
    }
  }

  void onPickerComplete(File file) {
    String base64Image = base64Encode(file.readAsBytesSync());
    folder.image = base64Image;
  }

  void openSelectContactForShare(BuildContext context) {
    if (!folder.shared) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectContacts(
                  onButtonPress: (p0) => onSharedSelect(context, p0),
                  title: AppLocalizations.of(context)!.addContacts,
                  subtitle: AppLocalizations.of(context)!.shareContactInFolder,
                  onlyTac: true,
                  alreadySelected: alreadyShared,
                  buttonText: AppLocalizations.of(context)!.confirmation,
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
      toShare = List.from(contacts);
    });
    Navigator.pop(context);

    return Future.value();
  }

  void save(BuildContext context) async {
    await update(context);
  }

  Future update(BuildContext context) async {
    try {
      folder.userid = user.tacUserId;
      await updateFolder(folder,
          folder.shared ? toShare.map((e) => e.tacUserId!).toList() : null);
      await widget.onSuccess();

      showSuccessToast(AppLocalizations.of(context)!.mod);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).backgroundColor,
          child: Center(child: CircularProgressIndicator(color: color)));
    } else {
      return Scaffold(
          body: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Platform.isAndroid ? 35 : 70, horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15))),
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
                            const Spacer(),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .7,
                                child: Text(
                                    "${AppLocalizations.of(context)!.modInphrase} ${folder.name}",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.headline1)),
                            const Spacer()
                          ]),
                      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Center(
                          child: FolderImagePicker(
                              initialImage: folder.image,
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
                              initalValue: folder.name,
                              onChange: ((p0) => setState(() {
                                    folder.name = p0;
                                  })))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: InputText(
                              label: AppLocalizations.of(context)!
                                  .folderDescription,
                              outsideLabel: true,
                              initalValue: folder.description,
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
                              AppLocalizations.of(context)!.connectToSalesforce,
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                      ?.withOpacity(
                                                          folder.shared
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
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          height: 60,
                                          child: getSharedInfo())
                                  ]))),
                      const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Center(
                          child: LoadingButton(
                              onPress: () => update(context),
                              text: AppLocalizations.of(context)!.save,
                              color: color,
                              borderColor: color))
                    ],
                  ))));
    }
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
