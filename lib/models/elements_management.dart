class ElementsManagement{
  bool linksBlocked = false;
  bool documentsBlocked = false;

  ElementsManagement();

  ElementsManagement.fromJson(Map<String, dynamic> json) {
    linksBlocked = json['item1'] as bool;
    documentsBlocked = json['item2'] as bool;
  }
}