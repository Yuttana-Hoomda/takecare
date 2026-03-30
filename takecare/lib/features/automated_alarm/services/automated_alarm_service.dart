import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AutomatedAlarmService {
  final ImagePicker _picker = ImagePicker();

  String get _baseUrl => Platform.isAndroid
      ? 'https://takecare-taupe.vercel.app/api'
      : 'https://takecare-taupe.vercel.app/api';

  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo?.path;
  }

  // ✅ POST /api/task-submissions
  Future<void> submitTask({
    required String taskId,
    required String taskTitle, // ใช้เป็น displayTitle ที่ส่งไป backend
    required String elderlyId,
    required String familyId,
    String? token,
    String? proofImgUrl,
  }) async {
    final uri = Uri.parse('$_baseUrl/task-submissions');

    debugPrint('📤 submitTask: $taskTitle ($taskId)');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'taskId': taskId,
        'displayTitle':
            taskTitle, // ✅ แก้จาก taskTitle → displayTitle ให้ตรงกับ backend
        'elderlyId': elderlyId,
        'familyId': familyId,
        'proofImgUrl': proofImgUrl,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ submitTask success');
    } else {
      debugPrint(
        '❌ submitTask error [${response.statusCode}]: ${response.body}',
      );
      throw Exception('Submit failed: ${response.statusCode}');
    }
  }
}
