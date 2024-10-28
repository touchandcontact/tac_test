class StripePriceDto {
  String? id;
  String? currency;
  double unitAmountDecimal;
  String? interval;
  int intervalCount;

  StripePriceDto({
    this.id,
    this.currency,
    required this.unitAmountDecimal,
    this.interval,
    required this.intervalCount,
  });

  factory StripePriceDto.fromJson(Map<String, dynamic> json) {
    return StripePriceDto(
      id: json["id"] as String?,
      currency: json["currency"] as String?,
      unitAmountDecimal: json["unitAmountDecimal"].toDouble(),
      interval: json["interval"] as String?,
      intervalCount: json["intervalCount"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "currency": currency,
      "unitAmountDecimal": unitAmountDecimal,
      "interval": interval,
      "intervalCount": intervalCount,
    };
  }
}
