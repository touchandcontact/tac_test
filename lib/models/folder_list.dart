import 'folder.dart';

class FolderList {
  int totalCount = 0;
  List<Folder> itemList = <Folder>[];

  FolderList();

  FolderList.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'] as int;
    if (json['itemList'] != null) {
      Iterable l = json['itemList'];
      itemList = List<Folder>.from(l.map((model) => Folder.fromJson(model)));
    }
  }
}
