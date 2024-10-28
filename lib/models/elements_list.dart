import 'package:tac/models/element_model.dart';

class ElementsList {
  int totalCount = 0;
  List<ElementModel> itemList = <ElementModel>[];

  ElementsList();

  ElementsList.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'] as int;
    if (json['itemList'] != null) {
      Iterable l = json['itemList'];
      itemList = List<ElementModel>.from(
          l.map((model) => ElementModel.fromJson(model)));
    }
  }
}
