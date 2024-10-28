import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tac/models/tac_user_device_model.dart';

import 'account_service.dart';

class TokenService {
  static final TokenService _tokenService =
  TokenService._internal();

  factory TokenService() {
    return _tokenService;
  }

  TokenService._internal();

  Future saveUserDeviceFunction(int userId) async {
    try {
      final tokenDevice = await getToken();
      if(tokenDevice != null){
        final deviceInfo = await getDeviceInfo();
        TacUserDeviceModel tacUserDeviceModel = TacUserDeviceModel(userId: userId,deviceToken: tokenDevice);
        tacUserDeviceModel.brand = deviceInfo.data.containsKey("brand") ?  deviceInfo.data["brand"] : null;
        tacUserDeviceModel.device = deviceInfo.data.containsKey("device") ?  deviceInfo.data["device"] : null;
        tacUserDeviceModel.model = deviceInfo.data.containsKey("model") ?  deviceInfo.data["model"] : null;
        await saveUserDevice(tacUserDeviceModel);
      }
    } on Exception catch (_) {
      debugPrint("errore nell'invio dell'user device");
    }
  }

  Future updateUserDeviceFunction(int userId) async {
    try {
      final tokenDevice = await getToken();
      if(tokenDevice != null){
        final deviceInfo = await getDeviceInfo();
        TacUserDeviceModel tacUserDeviceModel = TacUserDeviceModel(userId: userId,deviceToken: tokenDevice);
        tacUserDeviceModel.brand = deviceInfo.data.containsKey("brand") ?  deviceInfo.data["brand"] : null;
        tacUserDeviceModel.device = deviceInfo.data.containsKey("device") ?  deviceInfo.data["device"] : null;
        tacUserDeviceModel.model = deviceInfo.data.containsKey("model") ?  deviceInfo.data["model"] : null;
        await updateUserDevice(tacUserDeviceModel);
      }
    } on Exception catch (_) {
      debugPrint("errore nell'invio dell'user device");
    }
  }


  Future<BaseDeviceInfo> getDeviceInfo() async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late BaseDeviceInfo baseDeviceInfo;
    if (Platform.isAndroid) {
      baseDeviceInfo = await deviceInfo.androidInfo;
    } else {
      baseDeviceInfo = await deviceInfo.iosInfo;
    }
    return baseDeviceInfo;
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }


}
