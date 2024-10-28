import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/screens/contacts/ocr_screen/ocr_add_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/camera_app.dart';
import '../../../extentions/hexcolor.dart';
import '../../../services/ocr_service.dart';

class OcrLoadingScreen extends StatefulWidget {
  File image;
  int tacUserId;

  OcrLoadingScreen({Key? key, required this.image, required this.tacUserId})
      : super(key: key);

  @override
  State<OcrLoadingScreen> createState() => _OcrLoadingScreenState();
}

class _OcrLoadingScreenState extends State<OcrLoadingScreen> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  late Future<void> _ocrDataFuture;

  @override
  void initState() {
    _ocrDataFuture = _sendPhotoOcr();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8.8, 0, 0, 0),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ),
      body: Center(
          child: FutureBuilder<void>(
              future: _ocrDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _loadingWidget(),
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      _errorWidget(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buttonWidget(
                                AppLocalizations.of(context)!.cancel,
                                Theme.of(context).textTheme.headline2!.color!,
                                () => Navigator.pop(context),
                                Colors.grey[100]),
                            const SizedBox(
                              width: 8,
                            ),
                            _buttonWidget(
                                AppLocalizations.of(context)!.tryAgain, Colors.white, _openCamera, color),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  );
                }
                return const SizedBox();
              })),
    );
  }

  Future<void> _sendPhotoOcr() async {
    List<int> imageBytes = widget.image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    await getOcrData(widget.tacUserId, base64Image).then((value) =>
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    OcrAddScreen(contactMod: value, file: widget.image))));
  }

  _buttonWidget(label, colorText, onPressed, backgroundColor) {
    return Expanded(
        child: TextButton(
      child: _generateTextWidget(
        label,
        colorText,
      ),
      onPressed: onPressed,
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(16)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          backgroundColor: MaterialStateProperty.all(backgroundColor)),
    ));
  }

  _openCamera() async {
    List<CameraDescription> _cameras =
    await availableCameras();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CameraApp(
            camera: _cameras[0],
            user: widget.tacUserId),
      ),
    );
    // try {
    //   final image = await ImagePicker().pickImage(source: ImageSource.camera);
    //   if (image == null) return;
    //   widget.image = File(image.path);
    //   setState(() {
    //     _ocrDataFuture = _sendPhotoOcr();
    //   });
    // } on PlatformException catch (e) {
    //   print('Failed to pick image: $e');
    // }
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

  List<Widget> _loadingWidget() {
    return List<Widget>.from([
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(50.0)),
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(color: color),
      ),
      const SizedBox(
        height: 14,
      ),
      _generateTextWidget(
          AppLocalizations.of(context)!.wait, Theme.of(context).textTheme.headline2!.color!),
      const SizedBox(
        height: 20,
      ),
      _generateTextWidget(AppLocalizations.of(context)!.smartCardDataProcessing,
          Theme.of(context).textTheme.headline2!.color!,
          textAlign: TextAlign.center),
    ]).toList();
  }

  _errorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 120, color: Colors.red),
          const SizedBox(
            height: 40,
          ),
          _generateTextWidget(
              AppLocalizations.of(context)!.scanError, Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600, fontSize: 22),
          const SizedBox(
            height: 20,
          ),
          _generateTextWidget(
              AppLocalizations.of(context)!.ocrSmarcardError,
              Theme.of(context).textTheme.headline2!.color!,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
