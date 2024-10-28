class CardModel {

  String? paymentMethodId;
  String? expMonth;
  String? expYear;
  String? fullName;
  String? number;
  String? cvc;

  CardModel();

  CardModel.fromJson(Map<String, dynamic> json) {
    cvc = json["cvc"];
    expMonth = json["expMonth"];
    expYear = json["expYear"];
    fullName = json["fullName"];
    number = json["number"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["fullName"] = fullName;
    data["expMonth"] = expMonth;
    data["expYear"] =  expYear;
    data["number"] = number  ;
    data["cvc"] =cvc;
    data["paymentMethodId"] = paymentMethodId;
    return data;
  }
}