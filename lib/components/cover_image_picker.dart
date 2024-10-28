import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tac/helpers/permissions_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../extentions/hexcolor.dart';

class CoverImagePicker extends StatefulWidget {
  const CoverImagePicker(
      {Key? key,
      required this.onPickComplete,
      this.initialImage,
      this.radius,
      this.height,
      this.hideEditIcon = false,
      this.disabled = false})
      : super(key: key);
  final void Function(File) onPickComplete;
  final String? initialImage;
  final double? radius;
  final double? height;
  final bool hideEditIcon;
  final bool disabled;

  @override
  State<CoverImagePicker> createState() => CoverImagePickerState();
}

class CoverImagePickerState extends State<CoverImagePicker> {
  File? pickedImage;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  CoverImagePicker get widget => super.widget;

  Future pickImage() async {
    if (widget.disabled) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image;

    var permissionStatus = requestGalleryPermission();
    if ((Platform.isAndroid &&
            (await DeviceInfoPlugin().androidInfo).version.sdkInt < 33) ||
        await permissionStatus.isGranted) {
      image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);

        setState(() {
          pickedImage = selected;
        });
        widget.onPickComplete(selected);
      }
    } else {
      showErrorToast(AppLocalizations.of(context)!.permissionDenied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: pickImage,
        child: widget.initialImage != null && pickedImage == null
            ? Stack(clipBehavior: Clip.none, children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: widget.height == null ? 140 : widget.height!,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: widget.radius == null
                            ? null
                            : BorderRadius.all(Radius.circular(widget.radius!)),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.initialImage!)))),
                if (!widget.hideEditIcon)
                  Positioned(
                      top: 125,
                      right: 20,
                      child: GestureDetector(
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white,
                              ))))
              ])
            : pickedImage == null
                ? Stack(clipBehavior: Clip.none, children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: widget.height == null ? 140 : widget.height!,
                        decoration: BoxDecoration(
                            borderRadius: widget.radius == null
                                ? null
                                : BorderRadius.all(
                                    Radius.circular(widget.radius!)),
                            color: Theme.of(context).secondaryHeaderColor),
                        child: const SizedBox.shrink()),
                    Positioned(
                        top: 125,
                        right: 20,
                        child: GestureDetector(
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: color.computeLuminance() > 0.5
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .color
                                      : Colors.white,
                                ))))
                  ])
                : Stack(clipBehavior: Clip.none, children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: widget.height == null ? 140 : widget.height!,
                        decoration: BoxDecoration(
                            borderRadius: widget.radius == null
                                ? null
                                : BorderRadius.all(
                                    Radius.circular(widget.radius!)),
                            color: Theme.of(context).secondaryHeaderColor,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(pickedImage!)))),
                    if (!widget.hideEditIcon)
                      Positioned(
                          top: 125,
                          right: 20,
                          child: GestureDetector(
                              child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: color.computeLuminance() > 0.5
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color
                                        : Colors.white,
                                  ))))
                  ]));
  }
}
