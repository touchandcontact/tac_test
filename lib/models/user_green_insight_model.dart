class UserGreenInsightModel {
  int paperSaved;
  int waterSaved;
  double c02Saved;

  UserGreenInsightModel({
    required this.paperSaved,
    required this.waterSaved,
    required this.c02Saved,
  });

  factory UserGreenInsightModel.fromJson(Map<String, dynamic> json) {
    return UserGreenInsightModel(
      paperSaved: int.tryParse(json["paperSaved"].toString()) ?? 0,
      waterSaved: int.tryParse(json["waterSaved"].toString()) ?? 0,
      c02Saved: double.tryParse(json["c02Saved"].toString()) ?? 0.0,
    );
  }

}
