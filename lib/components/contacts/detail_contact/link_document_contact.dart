// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../enums/document_or_link_type.dart';
import '../../../extentions/hexcolor.dart';
import '../../../helpers/icons_helper.dart';
import '../../../helpers/permissions_helper.dart';
import '../../../helpers/snackbar_helper.dart';
import '../../../helpers/toast_helper.dart';
import '../../../models/element_model.dart';
import '../../../models/user.dart';
import '../../../services/contacts_services.dart';
import '../../../services/statistics_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LinkDocumentContact extends StatefulWidget {
  List<ElementModel> listaItem = [];
  int? tacUserId;
  String? identifier;
  bool isFromPreview;
  LinkDocumentContact({Key? key, required this.listaItem, this.tacUserId, this.identifier, this.isFromPreview = false}) : super(key: key);

  @override
  State<LinkDocumentContact> createState() => _LinkDocumentContactState();
}

class _LinkDocumentContactState extends State<LinkDocumentContact> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  @override
  Widget build(BuildContext context) {
    return GridView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16),
        children: widget.listaItem.map<Widget>((e) => _linkItem(e)).toList());
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 16,
          FontWeight fontWeight = FontWeight.w500,
          TextAlign? textAlign}) =>
      Text(
        value,
        textAlign: textAlign,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _linkItem(ElementModel item) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        onTap: () => _onTap(item),
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        title: Icon(getLinkIconFromString(item.icon),
            color: Theme.of(context).textTheme.headline1!.color),
        subtitle: _generateTextWidget(
            item.name, Theme.of(context).textTheme.headline1!.color!,
            fontSize: 12, textAlign: TextAlign.center),
      ),
    );
  }

  void share(String link) {
    Navigator.pop(context);
    Share.share(link);
  }

  download(ElementModel element) async {
    Navigator.pop(context);

    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          showErrorToast(AppLocalizations.of(context)!.folderError);
        }
      }
      await FlutterDownloader.enqueue(
          url: element.link,
          fileName: "${DateTime.now()}_${element.name}",
          savedDir: directory!.path,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true);
      if (Platform.isAndroid) {
        showSnackbar(
            context,
            AppLocalizations.of(context)!.downloadProgress,
            Colors.orange,
            duration: 1);
      } else {
        showSnackbar(context,  AppLocalizations.of(context)!.donwloadProgressWithoutMessage, Colors.orange,
            duration: 1);
      }
      if(!widget.isFromPreview){
        _saveIdentifier(widget.tacUserId, element.id);
      }
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.folderError);
    }
  }

  Future<void> _saveIdentifier(int? tacUserIdContact, int elementId) async {
    try{
      if(tacUserIdContact == null || tacUserIdContact == 0){
        tacUserIdContact = await getTacUserId(widget.identifier!);
      }
      await adddInsightUserDocDowloadCount(tacUserIdContact,user.tacUserId,elementId);
      // ignore: empty_catches
    }catch(e){
    }
  }


  void _onTap(ElementModel item) async {
    showAdaptiveActionSheet(
        context: context,
        androidBorderRadius: 20,
        bottomSheetColor: Theme.of(context).backgroundColor,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Row(children: [
                const Icon(Icons.share, size: 18),
                const Padding(padding: EdgeInsets.only(left: 10)),
                Text(AppLocalizations.of(context)!.share,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline1!.color))
              ]),
              onPressed: (context) {
                share(item.link);
              }),
          BottomSheetAction(
              title: item.type == DocumentOrLinkType.document
                  ? Row(children: [
                      const Icon(Icons.download, size: 18),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Text(AppLocalizations.of(context)!.downloadEng,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.headline1!.color))
                    ])
                  : Row(children: [
                      const Icon(Icons.link, size: 18),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Text(AppLocalizations.of(context)!.open,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.headline1!.color))
                    ]),
              onPressed: (context) {
                item.type == DocumentOrLinkType.document
                    ? download(item)
                    : _openLink(item);
              })
        ],
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))));
  }

  _openLink(item) async {
    Navigator.pop(context);
    if (!await launchUrl(Uri.parse(item.link))) {
      showErrorToast(AppLocalizations.of(context)!.linkError);
    }
    if(!widget.isFromPreview){
      _saveIdentifier(widget.tacUserId, item.id);
    }

  }
}
