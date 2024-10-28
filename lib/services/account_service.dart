import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tac/models/registry_request.dart';
import 'package:tac/models/user.dart';
import 'package:tac/models/user_edit.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/user_email.dart';
import 'package:tac/models/virtual_background_model.dart';

import '../constants.dart';
import '../models/app_user_card.dart';
import '../models/element_model.dart';
import '../models/field_management.dart';
import '../models/tac_user_device_model.dart';
import '../models/user_address.dart';
import '../models/user_telephone.dart';
import 'auth_service.dart';

Future<UserEditModel> getUserForEdit(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Account/GetUser?identifier=$identifier'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });
    if (response.statusCode == 200) {
      return UserEditModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String> getCompanyLogo(int companyId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Account/GetCompanyLogo?id=$companyId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return response.body.toString();
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future updateProfile(User user, List<UserTelephone> telephones,
    List<UserAddress> addresses, List<UserEmail> emails, File? profileImage, File? coverImage) async {
  try {
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Constants.apiUrl}/Account/UpdateUserProfile'));
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          "profileImage", profileImage.path,
          filename: "profileImage.png"));
    } else {
      user.profileImage = user.profileImage;
    }

    if (coverImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          "coverImage", coverImage.path,
          filename: "coverImage.png"));
    } else {
      user.coverImage = user.coverImage;
    }

    request.fields["user"] = jsonEncode(user);
    request.fields["addresses"] = addresses.isNotEmpty
        ? jsonEncode(addresses.map((e) => e.toJson()).toList())
        : "";
    request.fields["telephones"] = telephones.isNotEmpty
        ? jsonEncode(telephones.map((e) => e.toJson()).toList())
        : "";
    request.fields["emails"] = emails.isNotEmpty
        ? jsonEncode(emails.map((e) => e.toJson()).toList())
        : "";

    request.headers["Authorization"] =
        "Bearer ${await getAndEventuallyRefreshToken()}";

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception(response.reasonPhrase);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<List<FieldManagement>> listFieldManagement(
    int userId, int companyId) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/ListFieldManagement'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
      body: jsonEncode(
          <String, dynamic>{'userId': userId, 'companyId': companyId}),
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<FieldManagement>.from(
          l.map((model) => FieldManagement.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<VirtualBackgroundModel> getVirtualBackground(int userId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Account/GetVirtualBackground?idUser=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return VirtualBackgroundModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 204) {
      return VirtualBackgroundModel();
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future saveVirtualBackground(
    int userId, String color, String background) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/UpsertVirtualBackground'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'textColor': color,
        'background': background
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<Uint8List> downloadVirtualBackground(
    String link, String name, String role, String image, String color) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/CreateVirtualBackground'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'StringQrCodeText': link,
        'Name': name,
        'Role': role,
        'ImageBackgroundArray': image,
        'ColorHex': color
      }),
    );

    if (response.statusCode == 200) {
      return base64Decode(response.body);
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<List<AppUserCard>> getBusinessCards(int tacUserId) async {
  try {
    var response = await http.get(
      Uri.parse('${Constants.apiUrl}/Account/GetBusinessCards?id=$tacUserId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<AppUserCard>.from(
          l.map((model) => AppUserCard.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<void> toggleBusinessCard(int userCardId, bool value) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/ToggleBusinessCard'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userCardId': userCardId,
        'value': value,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<void> deleteBusinessCard(int cardId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.delete(
      Uri.parse('${Constants.apiUrl}/Account/DeleteBusinessCard?id=$cardId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<List<ElementModel>> getElementsForProfile(int tacUserId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/Account/GetElementsForProfile?id=$tacUserId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<ElementModel>.from(
          l.map((model) => ElementModel.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<bool> saveUserDevice(TacUserDeviceModel tacUserDeviceModel) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/SaveUserDevice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': tacUserDeviceModel.userId,
        'deviceToken': tacUserDeviceModel.deviceToken,
        'brand': tacUserDeviceModel.brand,
        'device': tacUserDeviceModel.device,
        'model': tacUserDeviceModel.model,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<bool> updateUserDevice(TacUserDeviceModel tacUserDeviceModel) async {
  try {
    var response = await http.put(
      Uri.parse('${Constants.apiUrl}/Account/UpdateUserDevice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': tacUserDeviceModel.userId,
        'deviceToken': tacUserDeviceModel.deviceToken,
        'brand': tacUserDeviceModel.brand,
        'device': tacUserDeviceModel.device,
        'model': tacUserDeviceModel.model,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<bool> updateStripeBilling(int userId, int billingId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Account/UpdateStripeBilling'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'billingId': billingId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<void> sendRegistryRequest(List<RegistryRequest> requests) async {
  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Constants.apiUrl}/Account/SendRegistryRequest'));
    request.fields["requests"] = requests.isNotEmpty
        ? jsonEncode(requests.map((e) => e.toJson()).toList())
        : "";
    request.headers["Authorization"] =
        "Bearer ${await getAndEventuallyRefreshToken()}";
    var response = await request.send();
    var respInt = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
    } else {
      throw Exception(respInt.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<void> setLanguage(int userId, String language) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Account/SetLanguage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            <String, dynamic>{'userId': userId, 'language': language}));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<String?> getLanguage(int userId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Account/GetLanguage?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else {
      return response.body;
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}


Future deleteUserAccount(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/Account/DeleteUserAccount?id=$identifier'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future logoutFromDevice(int id, String deviceToken) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/Account/Logout?userId=$id&token=$deviceToken'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future updateUserAccountEmail(String identifier, String email) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.patch(
        Uri.parse('${Constants.apiUrl}/Account/UpdateUserAccountEmail?identifier=$identifier&email=$email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}
