import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tac/extentions/hexcolor.dart';

class QrCodeScreen extends StatefulWidget {
  QrCodeScreen({super.key, this.isFromAssociateCard = false});

  bool isFromAssociateCard = false;

  @override
  State<StatefulWidget> createState() => QrCodeScreenState();
}

class QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanned = false;
  QRViewController? controller;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(!scanned){
        setState(() {
          scanned = true;
        });
        if (widget.isFromAssociateCard) {
          Navigator.pop(context, scanData.code);
        } else {
          String urlContact = scanData.code!.split('/').last;
          Navigator.pop(context, urlContact);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              cameraFacing: CameraFacing.back,
              formatsAllowed: const [BarcodeFormat.qrcode],
              overlay: QrScannerOverlayShape(
                  borderRadius: 10, borderColor: color, borderWidth: 2),
            ),
            // Positioned.fromRect(
            //     rect: Rect.fromCenter(
            //         center: Offset(MediaQuery.of(context).size.width / 2,
            //             MediaQuery.of(context).size.height / 2),
            //         width: 250,
            //         height: 250),
            //     child: Container(
            //       decoration: BoxDecoration(
            //           borderRadius: const BorderRadius.all(Radius.circular(20)),
            //           border:
            //               Border.all(color: Theme.of(context).primaryColor)),
            //     )),
            Positioned(
              left: 20,
              top: 40,
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
                          color: Theme.of(context).textTheme.bodyText1!.color),
                      color: Theme.of(context).textTheme.bodyText2!.color)),
            )
          ],
        ),
      ),
    );
  }
}
