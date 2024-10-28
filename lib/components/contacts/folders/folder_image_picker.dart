import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tac/helpers/permissions_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import '../../../extentions/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FolderImagePicker extends StatefulWidget {
  const FolderImagePicker(
      {Key? key, required this.onPickComplete, this.initialImage})
      : super(key: key);
  final void Function(File) onPickComplete;
  final String? initialImage;

  @override
  State<FolderImagePicker> createState() => FolderImagePickerState();
}

class FolderImagePickerState extends State<FolderImagePicker> {
  File? pickedImage;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  FolderImagePicker get widget => super.widget;

  Future pickImage() async {
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
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        image: DecorationImage(
                            image: NetworkImage(widget.initialImage!),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(30))),
                Positioned(
                    bottom: -10,
                    right: 0,
                    child: Container(
                        width: 30,
                        height: 30,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: color.computeLuminance() > 0.5
                              ? Theme.of(context).textTheme.bodyText2!.color
                              : Colors.white,
                        )))
              ])
            : pickedImage == null
                ? Stack(clipBehavior: Clip.none, children: [
                    Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                  constraints: BoxConstraints.loose(
                                      const Size.fromHeight(60.0)),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Positioned(
                                          top: -10,
                                          child: Icon(
                                            Icons.image,
                                            color: color,
                                            size: 70,
                                          ))
                                    ],
                                  ))
                            ])),
                    Positioned(
                        bottom: -10,
                        right: 0,
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: color.computeLuminance() > 0.5
                                  ? Theme.of(context).textTheme.bodyText2!.color
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
                    Positioned(
                        bottom: -10,
                        right: 0,
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: color.computeLuminance() > 0.5
                                  ? Theme.of(context).textTheme.bodyText2!.color
                                  : Colors.white,
                            )))
                  ]));
  }
}
