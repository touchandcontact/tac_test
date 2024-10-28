import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class OcrScreen extends StatefulWidget {
  /// Default Constructor
  const OcrScreen({Key? key}) : super(key: key);

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  late CameraController _cameraController;
  ValueNotifier<double> zoomNotifier = ValueNotifier(1.0);

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      _cameraController = CameraController(value[0], ResolutionPreset.max);
      _cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              // Handle access errors here.
              break;
            default:
              // Handle other errors here.
              break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.cyan,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: CameraPreview(
                  _cameraController,
               )),
            const Spacer(),
            ValueListenableBuilder(
                valueListenable: zoomNotifier,
                builder: (context, valueNotifier, child) {
                  return Slider(
                    onChanged: (value) {
                      zoomNotifier.value = value;
                      _changeZoom(value);
                    },
                    min: 1.0,
                    max: 8.0,
                    value: valueNotifier,
                  );
                }
            ),
            const SizedBox(height: 60,),
            Row(
              children: [
                const Spacer(),
                Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: IconButton(
                        splashRadius: 20,
                        onPressed: () => _onOffLight(),
                        icon: Icon(Icons.flash_on,
                            color: Theme.of(context).textTheme.bodyText1!.color),
                        color: Theme.of(context).textTheme.bodyText2!.color)),
                const Spacer(),
                Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: IconButton(
                        splashRadius: 20,
                        onPressed: () => _shootFoto(),
                        icon: Icon(Icons.camera,
                            color: Theme.of(context).textTheme.bodyText1!.color),
                        color: Theme.of(context).textTheme.bodyText2!.color)),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 60,),
          ],
        ),
      ),
    );
  }

  _shootFoto() async {
      if (!_cameraController.value.isInitialized) {return null;}
      if (_cameraController.value.isTakingPicture) {return null;}
      try {
        await _cameraController.setFlashMode(FlashMode.off);
        XFile picture = await _cameraController.takePicture();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PreviewPage(
              picture: picture,
            )));
      } on CameraException catch (e) {
        debugPrint('Error occured while taking picture: $e');
        return null;
    }
  }

  _changeZoom(double value){
    _cameraController.setZoomLevel(value);
  }

  _onOffLight(){
    if(_cameraController.value.flashMode == FlashMode.torch){
      _cameraController.setFlashMode(FlashMode.off);
    }else{
      _cameraController.setFlashMode(FlashMode.torch);
    }
  }
}

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(picture.name)
        ]),
      ),
    );
  }
}
