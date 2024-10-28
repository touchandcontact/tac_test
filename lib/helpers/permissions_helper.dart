import 'package:permission_handler/permission_handler.dart';

Future<PermissionStatus> requestCameraPermissions() async {
  await Permission.camera.request();
  return Permission.camera.status;
}

Future<PermissionStatus> requestGalleryPermission() async {
  await Permission.photos.request();
  return Permission.photos.status;
}

Future<PermissionStatus> requestExternalStoragPermissions() async {
  await Permission.manageExternalStorage.request();
  return Permission.manageExternalStorage.status;
}
