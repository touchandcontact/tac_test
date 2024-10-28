class RegistryRequest {
  int requestedById = 0;
  int companyId = 0;
  int state = 0;
  String title = "";
  String from = "-";
  String to = "";
  String propertyName = "";

  RegistryRequest({
    required this.requestedById,
    required this.companyId,
    required this.state,
    required this.title,
    required this.from,
    required this.to,
    required this.propertyName,
  });

  RegistryRequest.fromJson(Map<String, dynamic> json) {
    requestedById = int.parse(json['requestedById'].toString());
    companyId = int.parse(json['companyId'].toString());
    state = int.parse(json['state'].toString());
    title = json['title'];
    from = json['from'];
    to = json['to'];
    propertyName = json['propertyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["requestedById"] = requestedById;
    data["companyId"] = companyId;
    data["state"] = state;
    data["title"] = title;
    data["from"] = from;
    data["to"] = to;
    data["propertyName"] = propertyName;
    return data;
  }
}
