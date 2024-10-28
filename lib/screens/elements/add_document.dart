// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/tac_logo.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/services/elements_service.dart';

import '../../extentions/hexcolor.dart';
import '../../helpers/util.dart';
import '../../models/user.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({Key? key, required this.reload}) : super(key: key);
  final Future Function() reload;

  @override
  AddDocumentState createState() => AddDocumentState();
}

class AddDocumentState extends State<AddDocument> {
  double height = 120;
  double progressValue = 0;
  int progressPercentageValue = 0;
  bool error = false;
  bool isLoading = false;
  bool isSuccess = false;
  FilePickerResult? document;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  String? fileName;
  FocusNode fNode = FocusNode();

  @override
  AddDocument get widget => super.widget;

  @override
  void initState() {
    super.initState();
  }

  Future addDocument() async {
    if (document == null || document!.files.isEmpty) {
      showErrorToast("Caricare un file");
      return;
    }

    setState(() {
      error = false;
      isLoading = true;
      isSuccess = false;
    });

    ElementModel model = ElementModel();
    model.userId = user.tacUserId;
    model.name = fileName != null && fileName!.isNotEmpty ? "${fileName!}.${document!.files[0].name.split(".").last}" : document!.files[0].name;
    model.description = "";
    model.link = "";
    model.shared = false;
    model.sharedById = null;
    model.showOnProfile = false;
    model.type = DocumentOrLinkType.document;
    model.creationDate = DateTime.now();
    model.lastUpdate = DateTime.now();
    model.size = Util.transformBytesInMb(document!.files[0].size);

    try {
      await insertDocument(model, document!, setUploadProgress);
      await widget.reload();
      setState(() {
        error = false;
        isLoading = false;
        isSuccess = true;
      });
    } catch (e) {
      setState(() {
        error = true;
        isLoading = false;
        isSuccess = false;
      });
    }
  }

  Future openLibrary() async {
    try {
      fNode.unfocus();
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(withData: true, withReadStream: true);
      setState(() {
        document = result;
      });

      if (result != null) {
        await addDocument();
      }
    } catch (_) {
      setState(() {
        error = true;
      });
    }
  }

  Future resetError() {
    setState(() {
      error = false;
    });
    return Future.value();
  }

  Future goBack() {
    Navigator.pop(context);
    return Future.value();
  }

  void setUploadProgress(int sentBytes, int totalBytes) {
    double pValue =
        Util.remap(sentBytes.toDouble(), 0, totalBytes.toDouble(), 0, 1);
    pValue = double.parse(pValue.toStringAsFixed(2));

    if (pValue != progressValue) {
      setState(() {
        progressValue = pValue;
        progressPercentageValue = (pValue * 100.0).toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error) {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 50),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(AppLocalizations.of(context)!.loadingFile,
                              style: Theme.of(context).textTheme.headline1),
                        ))
                  ]))),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 1, child: SizedBox.shrink()),
                const Center(
                    child: Icon(Icons.cancel_outlined,
                        size: 150, color: Colors.red)),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          AppLocalizations.of(context)!.ops,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              color:
                                  Theme.of(context).textTheme.headline1!.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ))),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "${AppLocalizations.of(context)!.ops}! ${AppLocalizations.of(context)!.unknownError}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              color:
                                  Theme.of(context).textTheme.headline1!.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ))),
                Expanded(
                    flex: 2,
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingButton(
                                      onPress: () => goBack(),
                                      width: 140,
                                      text: AppLocalizations.of(context)!.cancel,
                                      textColor: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      borderColor: Theme.of(context)
                                          .secondaryHeaderColor),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 5)),
                                  LoadingButton(
                                      onPress: () => resetError(),
                                      width: 140,
                                      text: AppLocalizations.of(context)!.tryAgain,
                                      color: color,
                                      borderColor: color)
                                ]))))
              ]));
    } else if (isLoading) {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 50),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(AppLocalizations.of(context)!.loadingFile,
                              style: Theme.of(context).textTheme.headline1),
                        ))
                  ]))),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 1, child: SizedBox.shrink()),
                const Center(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TacLogo(forProfileImage: false, centered: true),
                )),
                Center(
                    child: Container(
                        margin: const EdgeInsets.only(top: 30),
                        height: 130,
                        width: 130,
                        child: progressValue == 1
                            ? const CircularProgressIndicator(
                                strokeWidth: 7,
                              )
                            : CircularProgressIndicator(
                                value: progressValue,
                                strokeWidth: 7,
                              ))),
                const Expanded(flex: 2, child: SizedBox.shrink())
              ]));
    } else if (isSuccess) {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 50),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(AppLocalizations.of(context)!.loadingFile,
                              style: Theme.of(context).textTheme.headline1),
                        ))
                  ]))),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 1, child: SizedBox.shrink()),
                const Center(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TacLogo(forProfileImage: false, centered: true),
                )),
                Center(
                    child: Icon(Icons.check_circle_outline,
                        size: 150, color: color)),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: Text(
                          "${AppLocalizations.of(context)!.loadFileSuccess}!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              color:
                                  Theme.of(context).textTheme.headline1!.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ))),
                Expanded(
                    flex: 2,
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: LoadingButton(
                                onPress: () => goBack(),
                                width: 200,
                                text: AppLocalizations.of(context)!.ok,
                                color: color,
                                borderColor: color))))
              ]));
    } else {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: IconButton(
                                splashRadius: 20,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.arrow_back,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .color))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(AppLocalizations.of(context)!.loadFile,
                              style: Theme.of(context).textTheme.headline1),
                        ))
                  ],
                ),
              )),
          body: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 1, child: SizedBox.shrink()),
                    Center(
                        child: Icon(FontAwesomeIcons.fileCirclePlus,
                            size: 90,
                            color:
                                Theme.of(context).textTheme.headline1!.color)),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              AppLocalizations.of(context)!.selectFileFromLibrary,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ))),
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextFormField(
                              textAlign: TextAlign.center,
                              autocorrect: false,
                              focusNode: fNode,
                              onChanged: setFile,
                              decoration: InputDecoration(
                                  hintText: "Inserisci nome file...",
                                  hintStyle: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline2!
                                              .color!))),
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color))),
                    ),

                    Expanded(
                        flex: 2,
                        child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: MaterialButton(
                                onPressed: () => {},
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 50),
                                    child: LoadingButton(
                                        onPress: openLibrary,
                                        width: 200,
                                        text: AppLocalizations.of(context)!.loadFile,
                                        color: color,
                                        borderColor: color)))))
                  ])));
    }
  }

  void setFile(String value) {
      fileName = value;
  }
}
