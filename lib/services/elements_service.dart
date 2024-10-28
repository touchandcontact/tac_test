import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:http/http.dart' as http;
import 'package:tac/models/element_model.dart';
import 'package:tac/models/elements_management.dart';
import '../constants.dart';
import '../models/elements_list.dart';
import 'auth_service.dart';

Future<ElementsList?> listElements(int userId, int page, int pageSize,
    DocumentOrLinkType type, String? searchedText) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse(
          '${Constants.apiUrl}/DocumentsOrLinks/${type == DocumentOrLinkType.document ? "SearchDocuments" : "SearchLink"}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'pageIndex': page,
        'pageSize': pageSize,
        'searchText': searchedText
      }),
    );

    if (response.statusCode == 200) {
      return ElementsList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future insertLink(ElementModel element) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/InsertUserLink'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': element.userId,
        'name': element.name,
        'description': element.description,
        'link': element.link,
        'type': element.type.index,
        'shared': element.shared,
        'sharedById': element.sharedById,
        'icon': element.icon,
        'showOnProfile': element.showOnProfile,
        'user': {}
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

Future deleteElements(List<int> toDelete) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.delete(
      Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/DeleteDocumentsOrLinks'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{'ids': toDelete}),
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

Future<String> updateShowOnProfile(int id, bool value) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/UpdateShowOnProfile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{'id': id, 'value': value}),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future updateShowOnProfileAll(
    int userId, bool value, DocumentOrLinkType type) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/UpdateShowOnProfileAll'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'value': value,
        'type': type.index
      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

Future<bool> getCheckedAll(int userId, DocumentOrLinkType type) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/DocumentsOrLinks/GetCheckedAll?userId=$userId&type=${type.index}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}

// Future insertDocument(ElementModel model, Uint8List bytes) async {
//   try {
//     var request = http.MultipartRequest('POST',
//         Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/InsertUserDocument'));

//     request.files
//         .add(http.MultipartFile.fromBytes("file", bytes, filename: model.name));
//     request.fields["model"] = jsonEncode(model.toJson());
//     request.headers["Authorization"] =
//         "Bearer ${await getAndEventuallyRefreshToken()}";

//     var response = await request.send();
//     if (response.statusCode != 200) {
//       throw Exception(response.reasonPhrase);
//     }
//   } on Exception catch (e) {
//     debugPrint("ERROR: $e");
//     throw Exception(e);
//   }
// }

Future insertDocument(ElementModel model, FilePickerResult file,
    Function(int, int) onUploadProgress) async {
  try {
    HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    final request = await httpClient.postUrl(
        Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/InsertUserDocument'));

    int byteCount = 0;

    var requestMultipart = http.MultipartRequest("POST",
        Uri.parse('${Constants.apiUrl}/DocumentsOrLinks/InsertUserDocument'));
    requestMultipart.files.add(http.MultipartFile.fromBytes(
        "file", file.files[0].bytes!,
        filename: file.files[0].name));
    requestMultipart.fields["model"] = jsonEncode(model.toJson());

    var msStream = requestMultipart.finalize();
    var totalByteLength = requestMultipart.contentLength;

    request.contentLength = totalByteLength;
    request.headers
        .set("Authorization", "Bearer ${await getAndEventuallyRefreshToken()}");
    request.headers
        .set('Content-Type', requestMultipart.headers['Content-Type']!);

    Stream<List<int>> streamUpload = msStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);

          byteCount += data.length;
          onUploadProgress(byteCount, totalByteLength);
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
        },
      ),
    );

    await request.addStream(streamUpload);

    final httpResponse = await request.close();
    var statusCode = httpResponse.statusCode;

    if (statusCode != 200) {
      throw Exception(
          'Error uploading file, Status code: ${httpResponse.statusCode}');
    }
  } catch (e) {
    debugPrint("ERROR: $e");
    throw Exception(e);
  }
}

Future<ElementsManagement> checkBlocked(int userId) async {
  try {
    var token = await getAndEventuallyRefreshToken();

    var response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/DocumentsOrLinks/CheckBlocked?userId=$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });

    if (response.statusCode == 200) {
      return ElementsManagement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  } on Exception catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    throw Exception(e);
  }
}
