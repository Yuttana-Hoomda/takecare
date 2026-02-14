import 'dart:developer';

import 'package:takecare/constants/enum.dart';
class User {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final Role role;
  final List<Disease>? diseases;
  final String? familyId;
  final String profilePictureUrl;

  User({required this.uid, required this.displayName, required this.phoneNumber, required this.role, this.diseases,  this.familyId, required this.profilePictureUrl });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        uid: json['uid']?.toString() ?? (throw 'uid is missing'),
        displayName: json['displayName']?.toString() ?? 'Unknown',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        role: Role.values.firstWhere(
              (r) => r.name == json['role'],
          orElse: () => Role.elder,
        ),
        diseases: (json['disease'] as List<dynamic>?)
            ?.map((d) => Disease.values.firstWhere((r) => r.name == d))
            .toList(),
        familyId: json['familyId']?.toString(),
        profilePictureUrl: json['profileImgUrl']?.toString() ?? '',
      );
    } catch (e, stacktrace) {
      log("❌ JSON Parsing Error: $e");
      log("❌ Stacktrace: $stacktrace");
      rethrow;
    }
  }
}