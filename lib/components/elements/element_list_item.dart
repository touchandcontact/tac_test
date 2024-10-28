// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tac/components/generic_dialog.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/icons_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/services/elements_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extentions/hexcolor.dart';
import '../../helpers/permissions_helper.dart';
import '../../helpers/snackbar_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ElementListItem extends StatefulWidget {
  const ElementListItem(
      {super.key,
      required this.element,
      required this.longPressMode,
      this.isChecked = false,
      this.onItemCheck,
      this.onLongPress,
      required this.isCompanyUserBlocked,
      required this.reloadAllChecked, this.isLocked = false});

  final ElementModel element;
  final bool longPressMode;
  final bool isChecked;
  final void Function(bool)? onItemCheck;
  final void Function()? onLongPress;
  final Future Function() reloadAllChecked;
  final bool isCompanyUserBlocked;
  final bool isLocked;

  @override
  State<ElementListItem> createState() => ElementListItemState();
}

class ElementListItemState extends State<ElementListItem> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  String path = "";

  @override
  ElementListItem get widget => super.widget;

  @override
  void initState() {
    setPath();
    super.initState();
  }

  void toggleShowOnProfile(bool value) async {
    showLoadingDialog(context);
    String resp = "";
    try {
      resp = await updateShowOnProfile(widget.element.id, value);
      if (!widget.isCompanyUserBlocked) {
        widget.element.showOnProfile = value;
        await widget.reloadAllChecked();
        setState(() {});
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        if (resp.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) {
                return GenericDialog(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                        child: Text(resp,
                            style: GoogleFonts.montserrat(fontSize: 16))));
              });
        } else {
          showSuccessToast(AppLocalizations.of(context)!.requestToLinkFile);
        }
      }
    } catch (_) {
      Navigator.pop(context);
      if(resp != null && resp.isNotEmpty){
        showDialog(
            context: context,
            builder: (context) {
              return GenericDialog(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                      child: Text(resp,
                          style: GoogleFonts.montserrat(fontSize: 16))));
            });
      }
      else{
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    }
  }

  setPath() async {
    var p = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      path = p;
    });
  }

  download() async {
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
          url: widget.element.link,
          fileName: "${DateTime.now()}_${widget.element.name}",
          savedDir: directory!.path,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true);
      if (Platform.isAndroid) {
        showSnackbar(context, AppLocalizations.of(context)!.downloadProgress,
            Colors.orange,
            duration: 1);
      } else {
        showSnackbar(
            context,
            AppLocalizations.of(context)!.donwloadProgressWithoutMessage,
            Colors.orange,
            duration: 1);
      }
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.folderError);
    }
  }

  openLink() async {
    Navigator.pop(context);
    if (!await launchUrl(Uri.parse(widget.element.link))) {
      showErrorToast("Impossibile aprire link");
    }
  }

  void share() {
    Navigator.pop(context);
    Share.share(widget.element.link);
  }

  void onTap() async {
    if (widget.longPressMode) {
      return;
    }
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
                share();
              }),
          BottomSheetAction(
              title: widget.element.type == DocumentOrLinkType.document
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
                widget.element.type == DocumentOrLinkType.document
                    ? download()
                    : openLink();
              })
        ],
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () => widget.onLongPress!(),
        onTap: onTap,
        child: Container(
            height: 60,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Theme.of(context).secondaryHeaderColor),
            child: Row(
              children: [
                if (widget.element.icon.isNotEmpty)
                  Icon(
                      widget.element.type == DocumentOrLinkType.document
                          ? getDocumentIconFromString(widget.element.icon)
                          : getLinkIconFromString(widget.element.icon),
                      size: 25,
                      color: Theme.of(context).textTheme.headline1!.color),
                const Padding(padding: EdgeInsets.only(left: 10)),
                Flexible(
                    fit: FlexFit.tight,
                    child: Text(widget.element.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.headline1!.color))),
                if (!widget.longPressMode && !widget.isLocked)
                  Transform.scale(
                      scale: 0.9,
                      child: CupertinoSwitch(
                          value: widget.element.showOnProfile,
                          activeColor:
                              Theme.of(context).textTheme.headline1!.color,
                          onChanged: toggleShowOnProfile))
                else if (!widget.element.shared &&
                    (widget.element.sharedById == null ||
                        widget.element.sharedById == 0))
                  Transform.scale(
                      scale: 1.4,
                      child: Checkbox(
                        checkColor: color.computeLuminance() > 0.5
                            ? Theme.of(context).textTheme.bodyText2!.color
                            : Colors.white,
                        fillColor: MaterialStateProperty.all(color),
                        value: widget.isChecked,
                        shape: const CircleBorder(),
                        onChanged: (bool? value) =>
                            widget.onItemCheck!(value ?? false),
                      ))
              ],
            )));
  }
}
