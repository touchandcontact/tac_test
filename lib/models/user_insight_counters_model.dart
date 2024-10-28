class UserInsightCountersModel {
  int tacCount;
  int profileViewCount;
  int documentsDownloadCount;
  int profileDowloadCount;
  int changeRateTacCount;
  int changeRateProfileViewCount;
  int changeRateDocumentsDowloadCount;
  int changeRateProfileDowloadCount;

  UserInsightCountersModel({
    required this.tacCount,
    required this.profileViewCount,
    required this.documentsDownloadCount,
    required this.changeRateTacCount,
    required this.changeRateProfileViewCount,
    required this.changeRateDocumentsDowloadCount,
    required this.profileDowloadCount,
    required this.changeRateProfileDowloadCount
  });

  factory UserInsightCountersModel.fromJson(Map<String, dynamic> json) {
    return UserInsightCountersModel(
      tacCount: int.tryParse(json["tacCount"].toString()) ?? 0,
      profileViewCount: int.tryParse(json["profileViewCount"].toString()) ?? 0,
      documentsDownloadCount: int.tryParse(json["documentsDownloadCount"].toString()) ?? 0,
      changeRateDocumentsDowloadCount: int.tryParse(json["changeRateDocumentsDowloadCount"].toString()) ?? 0,
      changeRateProfileViewCount: int.tryParse(json["changeRateProfileViewCount"].toString()) ?? 0,
      changeRateTacCount: int.tryParse(json["changeRateTacCount"].toString()) ?? 0,
      profileDowloadCount: int.tryParse(json["profileDowloadCount"].toString()) ?? 0,
      changeRateProfileDowloadCount: int.tryParse(json["changeRateProfileDowloadCount"].toString()) ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tacCount": tacCount,
      "profileViewCount": profileViewCount,
      "documentsDownloadCount": documentsDownloadCount,
      "changeRateDocumentsDowloadCount": changeRateDocumentsDowloadCount,
      "changeRateProfileViewCount": changeRateProfileViewCount,
      "changeRateTacCount": changeRateTacCount,
      "profileDowloadCount": profileDowloadCount,
      "changeRateProfileDowloadCount": changeRateProfileDowloadCount,
    };
  }
}
