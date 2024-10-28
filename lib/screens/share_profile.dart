import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phonenumbers/phonenumbers.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_share/social_share.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/buttons/long_grey_button.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/extentions/hexcolor.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../components/generic_dialog.dart';
import '../constants.dart';
import '../helpers/dialog_helper.dart';
import '../models/user.dart';
import '../services/vcard_service.dart';

class ShareProfile extends StatefulWidget {
  const ShareProfile({super.key});

  @override
  State<ShareProfile> createState() => _ShareProfileState();
}

class _ShareProfileState extends State<ShareProfile> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  late TwilioFlutter twilio;
  PhoneNumberEditingController phoneNumberController =
      PhoneNumberEditingController.fromCountryCode("IT");

  String? nameTo;

  @override
  void initState() {
    twilio = TwilioFlutter(
        accountSid: Constants.twilioSid,
        authToken: Constants.twilioAuthToken,
        twilioNumber: Constants.twilioNumber);
    super.initState();
  }

  @override
  void dispose() {
    phoneNumberController.dispose(); // to save environment
    super.dispose();
  }

  void openShareQrCode() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
              vertical: Platform.isAndroid
                  ? 190
                  : (MediaQuery.of(context).size.height > 845 ? 190 : 180),
              child: getShareWithQRCode(context));
        });
  }

  void openShareLink() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
              vertical: Platform.isAndroid
                  ? 190
                  : (MediaQuery.of(context).size.height > 845 ? 200 : 180),
              child: getShareWithLink(context));
        });
  }

  void openShareSMS() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(vertical: 150,child: getShareWithSMS(context),);
        });
  }

  void shareLink(String how) async {
    switch (how) {
      case "normal":
        await Share.share("${Constants.shareUrl}/${user.identifier}");
        break;
      case "whatsapp":
        SocialShare.shareWhatsapp("${Constants.shareUrl}/${user.identifier}");
        break;
      case "telegram":
        SocialShare.shareTelegram("${Constants.shareUrl}/${user.identifier}");
        break;
      default:
    }
  }

  void copyToClicpBoard() async {
    try {
      await Clipboard.setData(
          ClipboardData(text: "${Constants.shareUrl}/${user.identifier}"));

      showSuccessToast(AppLocalizations.of(context)!.copyLink);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.copyLinkError);
    }
  }

  Future<void> sendMessage() async {
    try {
      if (phoneNumberController.value == null ||
          !phoneNumberController.value!.isValid) {
        showErrorToast(AppLocalizations.of(context)!.insertValidPhone);
        return;
      }

      if (nameTo == null || nameTo!.isEmpty) {
        showErrorToast(AppLocalizations.of(context)!.insertRecipientName);
        return;
      }

      String text = sprintf(AppLocalizations.of(context)!.smsText, [
        nameTo,
        "${Constants.shareUrl}/${user.identifier}",
        user.name == null ? user.email : '${user.name} ${user.surname}'
      ]);
      await twilio.sendSMS(
          toNumber: phoneNumberController.value!.formattedNumber,
          messageBody: text);

      Navigator.pop(context);
      showSuccessToast(AppLocalizations.of(context)!.smsSended);
    } catch (e) {
      debugPrint(e.toString());
      showErrorToast(AppLocalizations.of(context)!.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Stack(
                children: [
                  Container(
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
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          color: Theme.of(context).textTheme.bodyText2!.color)),
                  Center(
                      child: Text(AppLocalizations.of(context)!.shareProfile,
                          style: Theme.of(context).textTheme.headline1))
                ],
              ),
            )),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Center(
                child: Image.asset('assets/images/condividiprofilo.jpg',
                    width: 230)),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Text(
                              AppLocalizations.of(context)!.shareSmartcard,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .color)))),
                  Align(
                      alignment: Alignment.center,
                      child: Text(AppLocalizations.of(context)!.useSmarcard,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .color))),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 3,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.1),
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.5),
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.9)
                                ],
                              )),
                            ),
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                        AppLocalizations.of(context)!.or,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .color)))),
                            Container(
                              width: 80,
                              height: 3,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.1),
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.5),
                                  Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!
                                      .withOpacity(0.9)
                                ],
                              )),
                            ),
                          ])),
                  Column(children: [
                    LongGrayButton(
                        onPress: openShareQrCode,
                        icon: Icons.qr_code_2,
                        fontSize: 16,
                        radius: 20,
                        padding: 15,
                        text: AppLocalizations.of(context)!.shareQrCode),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    LongGrayButton(
                        onPress: openShareLink,
                        icon: Icons.link,
                        fontSize: 16,
                        radius: 20,
                        padding: 15,
                        text: AppLocalizations.of(context)!.shareLink),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    LongGrayButton(
                        onPress: () => downloadDataByQrCode(context),
                        icon: Icons.download,
                        fontSize: 16,
                        radius: 20,
                        padding: 15,
                        text: "Qr Code Offline"),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    LongGrayButton(
                        onPress: downloadVcf,
                        icon: Icons.share,
                        fontSize: 16,
                        radius: 20,
                        padding: 15,
                        text: AppLocalizations.of(context)!.shareVcard),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    LongGrayButton(
                        onPress: openShareSMS,
                        icon: Icons.sms,
                        fontSize: 16,
                        radius: 20,
                        padding: 15,
                        text: AppLocalizations.of(context)!.shareWithSMS),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                  ])
                ],
              ),
            )
          ],
        )));
  }

  downloadVcf() async {
    showLoadingDialog(context);
    try {
      final response = await createVCard(user.identifier);
      Directory tempDir = await getTemporaryDirectory();
      final imagePath = "${tempDir.path}/${_returnNameOrEmail()}";
      final imageFile = File(imagePath);
      imageFile.writeAsBytesSync(base64Decode(response));
      final file = XFile(imagePath);
      await Share.shareXFiles([file]).then((value) => Navigator.pop(context));
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  downloadDataByQrCode(context) async {
    showLoadingDialog(context);
    try {
      dynamic response;
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        response = await Hive.box("settings").get("qrCodeOffline");
      } else {
        response = await createVCardStringWithIdentifier(user.identifier);
      }
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericDialog(
                vertical: 190,
                child: getShareWithQRCode(context, valueQrCode: response));
          });
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  _returnNameOrEmail() {
    if (user.name != null &&
        user.surname != null &&
        user.surname!.isNotEmpty &&
        user.name!.isNotEmpty) {
      return "${user.name} ${user.surname}.vcf";
    } else if (user.name != null && user.name!.isNotEmpty) {
      return "${user.name}.vcf";
    } else if (user.surname != null && user.surname!.isNotEmpty) {
      return "${user.surname}.vcf";
    } else if (user.email != null && user.email!.isNotEmpty) {
      return "${user.email}.vcf";
    }
    return "nd.vcf";
  }

  Widget getShareWithQRCode(BuildContext context, {String? valueQrCode}) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.shareWithQrCodeAlt,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(2.5),
              margin: const EdgeInsets.only(top: 20),
              child: QrImageView(
                padding: EdgeInsets.zero,
                version: QrVersions.auto,
                data: valueQrCode != null && valueQrCode != ""
                    ? valueQrCode
                    : "${Constants.shareUrl}/${user.identifier}",
                size: 200.0,
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(AppLocalizations.of(context)!.scanQrCode,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color)))
          ],
        ));
  }

  Widget getShareWithLink(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.shareLinkProfile,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Text(AppLocalizations.of(context)!.copyOrShare,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        border: Border.all(
                            color:
                                Theme.of(context).textTheme.headline2!.color!,
                            width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.link} ${AppLocalizations.of(context)!.profile}",
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.headline2!.color,
                              fontWeight: FontWeight.w500),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 3)),
                        Row(children: [
                          Expanded(
                              flex: 10,
                              child: Text(
                                  "${Constants.shareUrl}/${user.identifier}",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color,
                                      fontWeight: FontWeight.w600))),
                          GestureDetector(
                              onTap: copyToClicpBoard,
                              child: Icon(Icons.copy,
                                  size: 22,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color))
                        ])
                      ],
                    ))),
            Padding(
                padding: const EdgeInsets.fromLTRB(50, 40, 50, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color!,
                                width: 1)),
                        child: IconButton(
                            onPressed: () => shareLink("normal"),
                            color: Theme.of(context).backgroundColor,
                            icon: Icon(Icons.ios_share,
                                size: 25,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color))),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color!,
                                width: 1)),
                        child: IconButton(
                            onPressed: () => shareLink("whatsapp"),
                            color: Theme.of(context).backgroundColor,
                            icon: Icon(FontAwesomeIcons.whatsapp,
                                size: 30,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color))),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color!,
                                width: 1)),
                        child: IconButton(
                            onPressed: () => shareLink("telegram"),
                            color: Theme.of(context).backgroundColor,
                            icon: Icon(Icons.telegram,
                                size: 30,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .color)))
                  ],
                )),
          ],
        ));
  }

  Widget getShareWithSMS(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.shareWithSMS,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Text(AppLocalizations.of(context)!.shareWithSMSText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.telephone,
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.headline2!.color,
                              fontWeight: FontWeight.w500),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 3)),
                        Row(children: [
                          Expanded(
                              flex: 10,
                              child: PhoneNumberField(
                                controller: phoneNumberController,
                                countryCodeWidth: 55,
                                dialogTitle:
                                    AppLocalizations.of(context)!.selectCountry,
                                style: GoogleFonts.firaSans(color: Theme.of(context).textTheme.headline1!.color, fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                    fillColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    filled: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelStyle: GoogleFonts.montserrat(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .color,
                                        fontWeight: FontWeight.w600),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).errorColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).errorColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: const BorderRadius.all(Radius.circular(15))),
                                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor), borderRadius: const BorderRadius.all(Radius.circular(15))),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor), borderRadius: const BorderRadius.all(Radius.circular(15)))),
                              ))
                        ]),
                        const SizedBox(height: 5),
                        InputText(
                            label: AppLocalizations.of(context)!.recipientName,
                            onChange: (p0) => setState(() {
                                  nameTo = p0;
                                }))
                      ],
                    ))),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 40, 50, 0),
              child: SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                      color: color,
                      text: AppLocalizations.of(context)!.share,
                      width: 200,
                      borderColor: color,
                      onPress: sendMessage)),
            )
          ],
        ));
  }
}
