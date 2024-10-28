import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../screens/contacts/ocr_screen/ocr_loading_screen.dart';

class CameraApp extends StatefulWidget {
  dynamic camera;
  dynamic user;

  CameraApp({super.key, required this.camera, required this.user});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.veryHigh,
        enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        CameraPreview(
          controller,
          child: Center(
            child: Container(
              width: 320,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Spacer(),
                Expanded(
                    child: IconButton(
                  onPressed: takePicture,
                  iconSize: 50,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle, color: Colors.white),
                )),
                const Spacer(),
              ]),
            )),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(padding: const EdgeInsets.fromLTRB(15, 40, 0, 0), child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(15)),
                child: IconButton(
                    splashRadius: 20,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).textTheme.bodyText1!.color),
                    color: Theme.of(context).textTheme.bodyText2!.color)))),
      ]),
    );
  }

  Future takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    if (controller.value.isTakingPicture) {
      return null;
    }
    try {
      await controller.setFlashMode(FlashMode.off);
      XFile picture = await controller.takePicture();
      File file = File(picture.path);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              OcrLoadingScreen(image: file, tacUserId: widget.user),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }
}
