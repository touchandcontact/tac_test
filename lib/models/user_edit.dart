import 'package:tac/models/user.dart';
import 'package:tac/models/user_address.dart';
import 'package:tac/models/user_email.dart';
import 'package:tac/models/user_telephone.dart';

class UserEditModel {
  User userDTO = User();
  List<UserTelephone> userTelephoneDTO = <UserTelephone>[];
  List<UserAddress> userAddressDTO = <UserAddress>[];
  List<UserEmail> userEmailsDTO = <UserEmail>[];

  UserEditModel();

  UserEditModel.fromJson(Map<String, dynamic> json) {
    userDTO = User.fromJson(json["userDTO"]);
    if (json['userTelephoneDTO'] != null) {
      Iterable l = json['userTelephoneDTO'];
      userTelephoneDTO = List<UserTelephone>.from(
          l.map((model) => UserTelephone.fromJson(model)));
    }
    if (json['userAddressDTO'] != null) {
      Iterable l = json['userAddressDTO'];
      userAddressDTO =
          List<UserAddress>.from(l.map((model) => UserAddress.fromJson(model)));
    }
    if (json['userEmailsDTO'] != null) {
      Iterable l = json['userEmailsDTO'];
      userEmailsDTO =
      List<UserEmail>.from(l.map((model) => UserEmail.fromJson(model)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["userDTO"] = userDTO;
    data["userTelephoneDTO"] = userTelephoneDTO;
    data["userAddressDTO"] = userAddressDTO;
    data["userEmailsDTO"] = userEmailsDTO;
    return data;
  }
}
