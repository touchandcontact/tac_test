class StripeProductDto {
  String? id;
  String? name;
  String? description;
  String? defaultPriceId;
  bool? active;
  DateTime created;
  DateTime updated;

  StripeProductDto(
      {this.id,
        this.name,
        this.description,
        this.defaultPriceId,
        this.active,
        required this.created,
        required this.updated});

  factory StripeProductDto.fromJson(Map<String, dynamic> json) {
    return StripeProductDto(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      defaultPriceId: json["defaultPriceId"],
      active: json["active"] ?? false,
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "defaultPriceId": defaultPriceId,
      "active": active,
      "created": created.toIso8601String(),
      "updated": updated.toIso8601String(),
    };
  }
}
