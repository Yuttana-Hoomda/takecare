class ElderModel {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final String profilePictureUrl;

  ElderModel({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.profilePictureUrl,
  });

  factory ElderModel.fromJson(Map<String, dynamic> json) {
    return ElderModel(
      uid: json['uid']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Unknown',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profilePictureUrl: json['profileImgUrl']?.toString() ?? '',
    );
  }
}
