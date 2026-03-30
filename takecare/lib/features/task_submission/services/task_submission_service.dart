import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task_submission_model.dart';

class TaskSubmissionService {
  final String url = Platform.isAndroid
      ? 'https://takecare-taupe.vercel.app/api'
      : 'https://takecare-taupe.vercel.app/api';

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
        if (jsonData.containsKey('data')) {
          return TaskSubmission.fromJson(jsonData['data']);
        }
        return TaskSubmission.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to submit task: $err');
    }
  }

  // GET /task-submissions/family/:familyId
  Future<List<TaskSubmission>> getByFamily({
    required String familyId,
    required String token,
  }) async {
    try {
      // ✅ แก้ไขให้ตรงกับ Backend: /api/task-submissions/family/:familyId
      final String requestUrl = '$url/task-submissions/family/$familyId';
      
      debugPrint('=== GET SUBMISSIONS REQUEST ===');
      debugPrint('URL: $requestUrl');
      debugPrint('===============================');

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        debugPrint('🟢 GET SUBMISSIONS SUCCESS: ${response.body}');
        
        if (jsonData is List) {
          return jsonData
              .map((item) => TaskSubmission.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (jsonData is Map && jsonData.containsKey('data') && jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map((item) => TaskSubmission.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to get submissions: $err');
    }
  }
}
