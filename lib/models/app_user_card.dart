class AppUserCard {
  int id;
  int cardId;
  int vCardId;
  String? link;
  String? frontImage;
  String? backImage;
  int? companyCardDesignId;
  bool active;

  AppUserCard({
    required this.id,
    required this.cardId,
    required this.vCardId,
    this.link,
    this.backImage,
    this.companyCardDesignId,
    this.frontImage,
    this.active = false,
  });

  factory AppUserCard.fromJson(Map<String, dynamic> json) {
    return AppUserCard(
      id: int.parse(json["id"].toString()),
      cardId: int.parse(json["cardId"].toString()),
      vCardId: int.parse(json["vCardId"].toString()),
      link: json["link"]?.toString(),
      backImage: json["backImage"]?.toString(),
      frontImage: json["frontImage"]?.toString(),
      companyCardDesignId: json["companyCardDesignId"] == null ? null : int.parse(json["companyCardDesignId"].toString()),
      active: json["active"].toString().toLowerCase() == "true" ? true : false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cardId": cardId,
      "vCardId": vCardId,
      "link": link,
      "backImage": backImage,
      "frontImage": frontImage,
      "companyCardDesignId": companyCardDesignId,
      "active": active,
    };
  }
}
