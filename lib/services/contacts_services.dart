import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/contact.dart';
import 'package:tac/models/contact_company.dart';
import 'package:tac/models/contact_list.dart';
import 'package:tac/models/external_contact.dart';
import 'package:tac/models/folder_list.dart';
import 'package:tac/models/tag.dart';

import '../constants.dart';
import '../models/contact_company_list.dart';
import '../models/element_model.dart';
import '../models/external_contact_address.dart';
import '../models/external_contact_elephone.dart';
import '../models/folder.dart';
import '../models/folder_insert.dart';
import '../models/qr_contact_dto.dart';
import '../models/user_contact_info_model.dart';
import 'auth_service.dart';

Future<ContactList> listContacts(int userId, int page, int pageSize,
    String orderBy, bool orderDesc, List<int>? toExclude,
    {bool onlyTac = false}) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/GetUserContactList'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'idUser': userId,
        'pageIndex': page,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'toExclude': toExclude,
        'onlyTac': onlyTac
      }),
    );

    if (response.statusCode == 200) {
      return ContactList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<ContactList> searchContacts(int userId, int page, int pageSize,
    String orderBy, bool orderDesc, String? toSearch, List<int>? toExclude,
    {bool onlyTac = false,
    bool disablePaging = false,
    List<String>? tags}) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/SearchUserContact'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'searchText': toSearch,
        'pageIndex': page,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'toExclude': toExclude,
        'onlyTac': onlyTac,
        'disablePaging': disablePaging,
        'tags': tags
      }),
    );

    if (response.statusCode == 200) {
      return ContactList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<int> insertExternalContact(
    int userId,
    String notes,
    ExternalContact contact,
    File? profileImage,
    File? coverImage,
    List<ExternalContactAddress> addresses,
    List<ExternalContactTelephone> telephones) async {
  try {
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Constants.apiUrl}/Contact/InsertExternalContact'));
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          "profileImage", profileImage.path,
          filename: "profileImage.png"));
    }
    if (coverImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          "coverImage", coverImage.path,
          filename: "coverImage.png"));
    }

    request.fields["contact"] = jsonEncode(contact.toJson());
    request.fields["notes"] = notes;
    request.fields["userId"] = userId.toString();
    request.fields["addresses"] = addresses.isNotEmpty
        ? jsonEncode(addresses.map((e) => e.toJson()).toList())
        : "";
    request.fields["telephones"] = telephones.isNotEmpty
        ? jsonEncode(telephones.map((e) => e.toJson()).toList())
        : "";

    request.headers["Authorization"] =
        "Bearer ${await getAndEventuallyRefreshToken()}";

    var response = await request.send();
    var respInt = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      return int.parse(respInt.body);
    } else {
      throw Exception(respInt.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<bool> deleteContacts(List<int> ids) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/DeleteContacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{'IdList': ids}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<void> sendContacts(String sender, List<Contact> contacts, List<int> receivers) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/SendContacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
          <String, dynamic>{'Sender': sender, 'Contacts': contacts.map((e) => e.id).toList(), 'Receivers': receivers}),
    );

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

Future<ContactCompanyList> listCompanies(int userId, int page, int pageSize,
    String orderBy, bool orderDesc, List<int>? toExclude) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/GetUserContactCompanyList'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'idUser': userId,
        'pageIndex': page,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'toExclude': toExclude
      }),
    );

    if (response.statusCode == 200) {
      return ContactCompanyList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<ContactCompanyList> searchCompanies(
    int userId,
    int page,
    int pageSize,
    String orderBy,
    bool orderDesc,
    String? toSearch,
    List<int>? toExclude) async {
  try {
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/SearchUserContactCompany'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getAndEventuallyRefreshToken()}'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'searchText': toSearch,
        'pageIndex': page,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'toExclude': toExclude
      }),
    );

    if (response.statusCode == 200) {
      return ContactCompanyList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
  }
}

Future<void> sendCompanies(
    List<ContactCompany> contacts, List<int> receivers) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/SendCompanies'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(
          <String, dynamic>{'Items': contacts, 'receivers': receivers}),
    );

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

Future<FolderList> listFolders(int userId, int page, int pageSize,
    String orderBy, bool orderDesc, int shared,
    {String? searchText = ""}) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/GetUserContactFolderList'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'UserId': userId,
        'pageIndex': page,
        'shared': shared,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'searchText': searchText
      }),
    );

    if (response.statusCode == 200) {
      return FolderList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<Tag>> searchTags(String searchedText) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response =
        await http.post(Uri.parse('${Constants.apiUrl}/Contact/SearchTags'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(<String, dynamic>{'searchedText': searchedText}));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Tag>.from(l.map((model) => Tag.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<List<Tag>> listTagsByContacts(List<int> ids) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/ListTagsByContact'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{'userContactIds': ids}));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Tag>.from(l.map((model) => Tag.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future insertFolder(FolderInsert folder, List<int> folderContacts,
    List<int>? sharedWith) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/InsertUserContactFolder'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'ContactFolder': folder,
          'UserContactIdList': folderContacts,
          'SharedUserIdList': sharedWith
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<ContactList> listContactsByFolder(int folderId, int page, int pageSize,
    String orderBy, bool orderDesc, String? searchedText) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/GetFolderContacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'folderId': folderId,
        'pageIndex': page,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDesc': orderDesc,
        'searchedText': searchedText,
      }),
    );

    if (response.statusCode == 200) {
      return ContactList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<Folder> getFolder(int id) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Contact/GetFolder?id=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return Folder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future insertContactsToFolder(Folder folder, List<int> toInsert) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    folder.creationDate = null;
    
    var response = await http.put(
        Uri.parse('${Constants.apiUrl}/Contact/InsertContactsToFolder'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'ContactFolder': folder,
          'UserContactIdList': toInsert,
          'SharedUserIdList': null
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future deleteContactsFromFolder(int folderId, List<int> toDelete) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/Contact/DeleteContactsFromFolder'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'ContactFolder': folderId,
          'UserContactIdList': toDelete,
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<Contact>> getFolderSharedContacts(int userId, int id) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/GetFolderSharedContacts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'folderId': id,
        }));

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Contact>.from(l.map((model) => Contact.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future updateFolder(FolderInsert folder, List<int>? toShare) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/UpdateUserContactFolder'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'ContactFolder': folder,
          'SharedUserIdList': toShare,
        }));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future deleteFolder(int folderId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
        Uri.parse('${Constants.apiUrl}/Contact/DeleteContactFolder?id=$folderId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<UserContactInfoModel> getContact(int contactId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Contact/GetContact?id=$contactId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return UserContactInfoModel.fromJsonInternal(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<UserContactInfoModel> getExternalContact(int contactId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Contact/GetExternalContact?contactId=$contactId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return UserContactInfoModel.fromJsonExternal(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<List<ElementModel>> getContactDocumentAndLink(int userId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/Contact/GetContactDocumentAndLink?contactId=$userId'),
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
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<QrContactDto> getContactByIdentifier(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/Contact/GetContactByIdentifier?identifier=$identifier'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return QrContactDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<dynamic> upateContactNote(int contactId, String notes) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/UpateContactNote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'contactId': contactId,
        'notes': notes,
      }),
    );

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

Future<List<Tag>> listTagsByContact(int id) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Contact/ListTagsByContact?contactId=$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Tag>.from(l.map((model) => Tag.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<List<Tag>> listRecommendedTag(int tagNumber) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/Contact/ListRecommendedTag?max=$tagNumber'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Tag>.from(l.map((model) => Tag.fromJson(model)));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<bool> editContactTags(int contactId, List<Tag> listTags) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/EditContactTags'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            <String, dynamic>{'contactId': contactId, 'tags': listTags}));

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

Future<String> addContactToFavourite(int? userId, int contactId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/AddContactToFavourite'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            <String, dynamic>{'userId': userId, 'contactId': contactId}));

    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? response.body : "";
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<String> removeContactFromFavourite(int? userId, int contactId) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.post(
        Uri.parse('${Constants.apiUrl}/Contact/RemoveContactFromFavourite'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(
            <String, dynamic>{'userId': userId, 'contactId': contactId}));

    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? response.body : "";
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<String> getShareQrCode(int contactId, int dimensions) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/Contact/GetShareQrCode?contactId=$contactId&dimensions=$dimensions'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future editExternalContact(
    int userId,
    String notes,
    ExternalContact contact,
    File? profileImage,
    List<ExternalContactAddress> addresses,
    List<ExternalContactTelephone> telephones,
    int idContattoDaLista) async {
  try {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Constants.apiUrl}/Contact/EditExternalContact'));
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          "profileImage", profileImage.path,
          filename: "profileImage.png"));
    }

    request.fields["contact"] = jsonEncode(contact.toJson());
    request.fields["notes"] = notes;
    request.fields["userId"] = userId.toString();
    request.fields["contactId"] = idContattoDaLista.toString();
    request.fields["addresses"] = addresses.isNotEmpty
        ? jsonEncode(addresses.map((e) => e.toJson()).toList())
        : "";
    request.fields["telephones"] = telephones.isNotEmpty
        ? jsonEncode(telephones.map((e) => e.toJson()).toList())
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

Future<List<ElementModel>> getElementsByIdentifier(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/Contact/GetElementsByIdentifier?identifier=$identifier'),
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
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<bool> insertContact(String contactIdentifier, int userId, String? notes,
    List<Tag> tagList) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response =
        await http.post(Uri.parse('${Constants.apiUrl}/Contact/InsertContact'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(<String, dynamic>{
              'contactIdentifier': contactIdentifier,
              'userId': userId,
              'notes': notes,
              'tagList': tagList,
            }));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<int> getTacUserId(String identifier) async {
  try {
    var token = await getAndEventuallyRefreshToken();
    var response = await http.get(
        Uri.parse('${Constants.apiUrl}/Contact/GetTacUserId?identifier=$identifier'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<ContactList> getCompanyContacts(int userId,int companyId, int page, int pageSize,
    String orderBy, bool orderDesc, String? searchedText) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/Contact/GetCompanyContacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "orderBy": orderBy,
        "orderDesc": orderDesc,
        "pageIndex": page,
        "pageSize": pageSize,
        "companyId": companyId,
        "userId": userId,
        "searchedText": searchedText
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return ContactList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}