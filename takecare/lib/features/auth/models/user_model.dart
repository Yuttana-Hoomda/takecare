import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';

class MealSchedule {
  final TimeOfDay breakfast;
  final TimeOfDay lunch;
  final TimeOfDay dinner;

  const MealSchedule({
    required this.breakfast,
    required this.lunch,
    required this.dinner
  });

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    return MealSchedule(
      breakfast: TimeOfDay(
        hour: json['breakfast']['hour'],
        minute: json['breakfast']['minute'],
      ),
      lunch: TimeOfDay(
        hour: json['lunch']['hour'],
        minute: json['lunch']['minute'],
      ),
      dinner: TimeOfDay(
        hour: json['dinner']['hour'],
        minute: json['dinner']['minute'],
      ),
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'breakfast': {'hour': breakfast.hour, 'minute': breakfast.minute},
        'lunch': {'hour': lunch.hour, 'minute': lunch.minute},
        'dinner': {'hour': dinner.hour, 'minute': dinner.minute},
      };
}

class BaseUser {
  final String uid;
  final String displayName;
  final String phoneNumber;
  final String profilePictureUrl;
  final String? familyId;
  final Role role;

  const BaseUser({
    required this.uid,
    required this.displayName,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.role,
    this.familyId,
  });
}

class ElderUser extends BaseUser {
  final List<Diseases>? ncdConditions;
  final MealSchedule foodTime;

  const ElderUser({
    required super.uid,
    required super.displayName,
    required super.phoneNumber,
    required super.profilePictureUrl,
    super.familyId,
    this.ncdConditions,
    required this.foodTime
  }) : super(role: Role.elder);

  factory ElderUser.fromJson(Map<String, dynamic> json) {
    try {
      return ElderUser(
        uid: json['uid']?.toString() ?? (throw 'uid is missing'),
        displayName: json['displayName']?.toString() ?? 'Unknown',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        familyId: json['familyId']?.toString(),
        profilePictureUrl: json['profileImgUrl']?.toString() ?? '',
        ncdConditions: json['ncdConditions'] != null
            ? List<String>.from(json['ncdConditions'])
            .map((e) => Diseases.values.byName(e))
            .toList()
            : null,
        foodTime: MealSchedule.fromJson(json['foodTime']),
      );
    } catch (e, stacktrace) {
      log("❌ JSON Parsing Error: $e");
      log("❌ Stacktrace: $stacktrace");
      rethrow;
    }
  }
}

class CaregiverUser extends BaseUser {
  const CaregiverUser({
    required super.uid,
    required super.displayName,
    required super.phoneNumber,
    super.familyId,
    required super.profilePictureUrl,
  }) : super(role: Role.caregiver);

  factory CaregiverUser.fromJson(Map<String, dynamic> json) {
    try {
      return CaregiverUser(
        uid: json['uid']?.toString() ?? (throw 'uid is missing'),
        displayName: json['displayName']?.toString() ?? 'Unknown',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
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

class PendingUser extends BaseUser {
  const PendingUser({
    required super.uid,
    required super.displayName,
    required super.phoneNumber,
    super.familyId,
    required super.profilePictureUrl,
  }) : super(role: Role.pending);

  factory PendingUser.fromJson(Map<String, dynamic> json) {
    try {
      return PendingUser(
        uid: json['uid']?.toString() ?? (throw 'uid is missing'),
        displayName: json['displayName']?.toString() ?? 'Unknown',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        familyId: json['familyId']?.toString(),
        profilePictureUrl: json['profileImgUrl']?.toString() ?? '',
      );
    } catch (e, stacktrace) {
      log("❌ JSONParsing Error: $e");
      log("❌ Stacktrace: $stacktrace");
      rethrow;
    }
  }
}

BaseUser userFromJson(Map<String, dynamic> json) {
    switch (json['role']) {
      case 'elder':
        return ElderUser.fromJson(json);
      case 'caregiver':
        return CaregiverUser.fromJson(json);
      case 'pending':
        return PendingUser.fromJson(json);
      default:
        throw Exception('Unknown role: ${json['role']}');
    }
}