class TacUserDeviceModel {
  int userId;
  String? deviceToken;
  String? brand;
  String? device;
  String? model;

  TacUserDeviceModel({
    required this.userId,
    this.deviceToken,
    this.brand,
    this.device,
    this.model,
  });

  factory TacUserDeviceModel.fromJson(Map<String, dynamic> json) {
    return TacUserDeviceModel(
      userId: json["userId"] as int,
      deviceToken: json["deviceToken"] as String?,
      brand: json["brand"] as String?,
      device: json["device"] as String?,
      model: json["model"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "deviceToken": deviceToken,
      "brand": brand,
      "device": device,
      "model": model,
    };
  }
}
