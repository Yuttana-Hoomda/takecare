import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task_submission_model.dart';

class TaskSubmissionService {
  final String url = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  // POST /task-submissions
  Future<TaskSubmission> submit({
    required String taskId,
    required String elderlyId,
    required String familyId,
    required String displayTitle,
    required String token,
    String? proofImgUrl,
  }) async {
    try {
      final body = {
        'taskId': taskId,
        'elderlyId': elderlyId,
        'familyId': familyId,
        'displayTitle': displayTitle,
        'proofImgUrl': proofImgUrl,
      };

      debugPrint('=== SUBMIT TASK REQUEST ===');
      debugPrint('URL: $url/task-submissions');
      debugPrint('Token: $token');
      debugPrint('Body: ${jsonEncode(body)}');
      debugPrint('===========================');

      final response = await http.post(
        Uri.parse('$url/task-submissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('=== SUBMIT TASK RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('============================');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return TaskSubmission.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to submit task: $err');
    }
  }

  // GET /task-submissions?familyId=
  Future<List<TaskSubmission>> getByFamily({
    required String familyId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$url/task-submissions?familyId=$familyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return jsonData
            .map((item) => TaskSubmission.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to get submissions: $err');
    }
  }
}