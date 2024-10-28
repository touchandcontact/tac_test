import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tac/components/tac_logo.dart';
import 'package:tac/helpers/permissions_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../extentions/hexcolor.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker(
      {Key? key,
      required this.onPickComplete,
      this.initialImage,
      this.iconOnRight = false,
      this.useBoxShadow = false,
      this.enabled = true})
      : super(key: key);
  final void Function(File) onPickComplete;
  final String? initialImage;
  final bool iconOnRight;
  final bool useBoxShadow;
  final bool enabled;

  @override
  State<ProfileImagePicker> createState() => ProfileImagePickerState();
}

class ProfileImagePickerState extends State<ProfileImagePicker> {
  File? pickedImage;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  ProfileImagePicker get widget => super.widget;

  Future pickImage() async {
    if (!widget.enabled) return;

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
        child: widget.initialImage != null &&  widget.initialImage != "" && pickedImage == null
            ? Stack(clipBehavior: Clip.none, children: [
                Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        image: DecorationImage(
                            image: NetworkImage(widget.initialImage!),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(30))),
                if (widget.enabled)
                  Positioned(
                      bottom: widget.iconOnRight ? -5 : -20,
                      left: widget.iconOnRight ? 75 : 40,
                      child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                          child: Icon(
                            Icons.photo_camera,
                            size: 20,
                            color: color.computeLuminance() > 0.5
                                ? Theme.of(context).textTheme.bodyText2!.color
                                : Colors.white,
                          ))),
              ])
            : pickedImage == null
                ? Stack(clipBehavior: Clip.none, children: [
                    Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            boxShadow: widget.useBoxShadow
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color!,
                                      offset: const Offset(0.0, 0),
                                      blurRadius: 1.0,
                                    )
                                  ]
                                : null,
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const TacLogo(forProfileImage: true),
                              Container(
                                  constraints: BoxConstraints.loose(
                                      const Size.fromHeight(60.0)),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Positioned(
                                          top: -10,
                                          child: Icon(
                                            Icons.person,
                                            color: color,
                                            size: 70,
                                          ))
                                    ],
                                  ))
                            ])),
                    if (widget.enabled)
                      Positioned(
                          bottom: widget.iconOnRight ? -5 : -20,
                          left: widget.iconOnRight ? 75 : 40,
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              child: Icon(
                                Icons.photo_camera,
                                size: 20,
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white,
                              ))),
                  ])
                : Stack(clipBehavior: Clip.none, children: [
                    Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            image: DecorationImage(
                                image: FileImage(pickedImage!),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(30))),
                    if (widget.enabled)
                      Positioned(
                          bottom: widget.iconOnRight ? -5 : -20,
                          left: widget.iconOnRight ? 75 : 40,
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                              child: Icon(
                                Icons.photo_camera,
                                size: 20,
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white,
                              )))
                  ]));
  }
}
