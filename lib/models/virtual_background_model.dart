class VirtualBackgroundModel {
  String image = "";
  String textColor = "";

  VirtualBackgroundModel();

  VirtualBackgroundModel.fromJson(Map<String, dynamic> json) {
    image = json["image"];
    textColor = json["textColor"];
  }
}
