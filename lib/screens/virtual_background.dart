// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tac/components/cover_image_picker.dart';
import 'package:tac/components/generic_error.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/components/virtual_background_loader.dart';
import 'package:tac/constants.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/material_color_helper.dart';
import 'package:tac/helpers/snackbar_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/virtual_background_model.dart';
import 'package:tac/services/account_service.dart';
import 'package:http/http.dart' as http;

import '../components/buttons/loading_button.dart';
import '../extentions/hexcolor.dart';
import '../helpers/permissions_helper.dart';
import '../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VirtualBackground extends StatefulWidget {
  const VirtualBackground({Key? key}) : super(key: key);

  @override
  VirtualBackgroundState createState() => VirtualBackgroundState();
}

class VirtualBackgroundState extends State<VirtualBackground> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  VirtualBackgroundModel? model;
  bool isError = false;
  bool isLoading = false;
  bool canDownload = true;
  Uint8List? fakeQrCode;
  TextEditingController colorController = TextEditingController();

  String name = "";
  String surname = "";
  String role = "";
  String link = "";
  bool disabled = false;
  Color selectedColor = HexColor.fromHex("ffffff");
  Color pickerColor = HexColor.fromHex("ffffff");
  File? pickedImage;

  List<String> availableColors = [
    "#FF4A4A",
    "#FF4A89",
    "#FF9E4A",
    "#FFCE4A",
    "#4AFFDC",
    "#1BDE75",
    "#1BDE75",
    "#006EB3",
    "#7A3CEF",
    "#CD3CEF",
    "#0037B3",
    "#623405",
    "#00B0B3"
  ];

  @override
  void initState() {
    // getFakeQrCode();
    load();
    super.initState();
  }

  Future download() async {
    try {
      var response = await http.get(Uri.parse(model!.image));
      var toDownload = await downloadVirtualBackground(link, "$name $surname",
          role, base64Encode(response.bodyBytes), selectedColor.toHex());
      Directory? directory;
      try {
        if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        }
      } catch (_) {
        showErrorToast(AppLocalizations.of(context)!.folderError);
      }

      File file = File("${directory!.path}/VirtualBackground.png");
      if (!(await file.exists())) {
        await file.create(recursive: true);
      }
      await file.writeAsBytes(toDownload);

      showSnackbar(
          context,
          AppLocalizations.of(context)!.downloadCompleted,
          Colors.green,
          duration: 2);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.downloadError);
    }
  }

  Future downloadAlert() async {
    var permission = await requestExternalStoragPermissions();
    if (Platform.isIOS || permission.isGranted) {
      if (disabled) {
        await download();
        return;
      }
      Widget cancelButton = OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).secondaryHeaderColor)),
        child: Text(AppLocalizations.of(context)!.cancel,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headline2!.color)),
        onPressed: () => Navigator.pop(context),
      );

      Widget continueButton = OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
        ),
        child: Text(AppLocalizations.of(context)!.confirmation,
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: color.computeLuminance() > 0.5
                    ? Theme.of(context).textTheme.bodyText2!.color
                    : Colors.white)),
        onPressed: () async {
          Navigator.pop(context);
          await download();
        },
      );
      AlertDialog alert = AlertDialog(
          title: Text(AppLocalizations.of(context)!.downloadVirtualBackground),
          content: Text(
              AppLocalizations.of(context)!.saveModBeforeDownload,
              style: GoogleFonts.montserrat(fontSize: 14)),
          actions: [
            cancelButton,
            continueButton,
          ]);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      showErrorToast(AppLocalizations.of(context)!.permissionDenied);
    }
  }

  save() async {
    showLoadingDialog(context);

    try {
      if (pickedImage == null && (model == null || model!.image.isEmpty)) {
        showErrorToast(AppLocalizations.of(context)!.imgRequired);
        return;
      }

      if (!isColor(selectedColor.toHex())) {
        showErrorToast(AppLocalizations.of(context)!.colorError);
        return;
      }

      String image = "";
      if (pickedImage != null) {
        List<int> imageBytes = pickedImage!.readAsBytesSync();
        image = base64Encode(imageBytes);
      } else {
        image = model!.image;
      }
      await saveVirtualBackground(user.tacUserId, selectedColor.toHex(), image);
      await load();
      setState(() {
        canDownload = true;
      });
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }

    Navigator.pop(context);
  }

  // getFakeQrCode() async {
  //   try {
  //     var qrString =
  //         await getQRCode("${Constants.shareUrl}/${user.identifier}", 80);
  //     if (qrString.isNotEmpty) {
  //       setState(() {
  //         fakeQrCode = base64Decode(qrString);
  //       });
  //     }
  //   } catch (_) {
  //     showErrorToast(AppLocalizations.of(context)!.qrCodeError);
  //   }
  // }

  load() async {
    try {
      setState(() {
        isLoading = true;
      });

      var result = await getVirtualBackground(user.tacUserId);

      setState(() {
        model = result;
        if (model != null && model!.textColor != "") {
          selectedColor = HexColor.fromHex(model!.textColor);
        } else {
          canDownload = false;
        }

        colorController.text = selectedColor.toHex();
        name = user.name ?? "";
        surname = user.surname ?? "";
        if(user.companyId != null && user.roles != null && user.roles!.isNotEmpty) {
          role = user.roles![0];
        } else {
          role = "";
        }
        link = "${Constants.shareUrl}/${user.identifier}";
        disabled = user.companyId != null && user.companyId! > 0;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future resetError() async {
    setState(() {
      isError = false;
    });
    await load();
  }

  onPickImageComplete(File file) {
    setState(() {
      pickedImage = file;
    });
  }

  changeLink(String string) {
    setState(() {
      link = string;
    });
  }

  changeName(String string) {
    setState(() {
      name = string;
    });
  }

  changeSurname(String string) {
    setState(() {
      surname = string;
    });
  }

  changeRole(String string) {
    setState(() {
      role = string;
    });
  }

  changeColor(String string) {
    if (!isColor(string)) {
      return;
    }
    setState(() {
      selectedColor = HexColor.fromHex(string);
      pickerColor = HexColor.fromHex(string);
    });
  }

  void changePickerColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            flexibleSpace: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Stack(children: [
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
                              onPressed: () => {Navigator.pop(context)},
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
                        child: Text(AppLocalizations.of(context)!.virtualBackground,
                            style: Theme.of(context).textTheme.headline1),
                      )),
                  if (!disabled)
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => save(),
                              child: Text(AppLocalizations.of(context)!.save,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: color,
                                      fontWeight: FontWeight.w600)),
                            )))
                ]))),
        body: isError
            ? GenericError(onPress: resetError)
            : isLoading
                ? const VirtualBackgroundLoader()
                : SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(children: [
                      SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.virtualBackground,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Stack(children: [
                                    CoverImagePicker(
                                        onPickComplete: onPickImageComplete,
                                        radius: 10,
                                        height: 150,
                                        hideEditIcon: true,
                                        disabled: disabled,
                                        initialImage: model != null && model!.image != ""
                                            ? model!.image
                                            : null),
                                      Positioned(
                                          top: 10,
                                          left: 10,
                                          child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              child: Container(
                                                  color: Colors.white,
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  height: 60,
                                                  width: 60,
                                                  child: QrImageView(
                                                    data: "${Constants.shareUrl}/${user.identifier}",
                                                    version: QrVersions.auto,
                                                    size:120.0,
                                                  )))),
                                    Positioned(
                                        right: 10,
                                        top: 10,
                                        child: model == null
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                    Text(
                                                      "${AppLocalizations.of(context)!.name} ${AppLocalizations.of(context)!.surname}",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              color:
                                                                  selectedColor,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(context)!.role,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              color:
                                                                  selectedColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    )
                                                  ])
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                    Text(
                                                      "$name $surname",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              color:
                                                                  selectedColor,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Text(
                                                      role,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              color:
                                                                  selectedColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    )
                                                  ]))
                                  ])),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(AppLocalizations.of(context)!.qrCode,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(children: [
                                    Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline1!
                                                    .color!)),
                                        height: 60,
                                        width: 60,
                                        child: QrImageView(
                                          data: "${Constants.shareUrl}/${user.identifier}",
                                          version: QrVersions.auto,
                                          size: 120.0,
                                        )),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 15)),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.68,
                                      child: InputText(
                                          initalValue: link,
                                          enabled: !disabled,
                                          label: AppLocalizations.of(context)!.qrCodeLink,
                                          onChange: changeLink))
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(AppLocalizations.of(context)!.info,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Column(children: [
                                    InputText(
                                        label: AppLocalizations.of(context)!.name,
                                        onChange: changeName,
                                        enabled: !disabled,
                                        initalValue: name),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                    InputText(
                                        label: AppLocalizations.of(context)!.surname,
                                        onChange: changeSurname,
                                        enabled: !disabled,
                                        initalValue: surname),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                    InputText(
                                        label: AppLocalizations.of(context)!.role,
                                        onChange: changeRole,
                                        enabled: !disabled,
                                        initalValue: role)
                                  ])),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(AppLocalizations.of(context)!.colorSettings,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.62,
                                      child: InputText(
                                          label: AppLocalizations.of(context)!.textColor,
                                          controller: colorController,
                                          enabled: !disabled,
                                          onChange: changeColor),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(left: 10)),
                                    Container(
                                        width: 80,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            color: selectedColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: selectedColor ==
                                                    Colors.white
                                                ? Border.all(
                                                    width: 2,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor)
                                                : null))
                                  ])),
                              if (!disabled)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: SizedBox(
                                        width: double.infinity,
                                        height: 30,
                                        child: Center(
                                            child: Text(
                                                AppLocalizations.of(context)!.orSelectColor,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline2!
                                                        .color,
                                                    fontWeight:
                                                        FontWeight.w600))))),
                              if (!disabled)
                                SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: getColors())),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 70))
                            ],
                          )),
                      if (model != null &&
                          model!.image.isNotEmpty &&
                          canDownload)
                        Positioned.fill(
                            bottom: 15,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: LoadingButton(
                                    onPress: downloadAlert,
                                    width: 150,
                                    text: AppLocalizations.of(context)!.download,
                                    color: color,
                                    borderColor: color)))
                    ])));
  }

  List<Widget> getColors() {
    List<Widget> result = <Widget>[];
    for (var i = 0; i < availableColors.length; i++) {
      result.add(GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = HexColor.fromHex(availableColors[i]);
              colorController.text = selectedColor.toHex();
            });
          },
          child: Container(
              width: 80,
              height: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  color: HexColor.fromHex(availableColors[i]),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: HexColor.fromHex(availableColors[i]) == Colors.white
                      ? Border.all(
                          color: Theme.of(context).textTheme.headline2!.color!)
                      : null))));
    }

    return result;
  }
}
