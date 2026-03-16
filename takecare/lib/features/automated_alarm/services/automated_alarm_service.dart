import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AutomatedAlarmService {
  final ImagePicker _picker = ImagePicker();
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo?.path;
  }

  // ✅ POST /api/task-submissions (ไม่มีรูปก่อนในการเทส)
  Future<void> submitTask({
    required String taskId,
    required String taskTitle,
    required String elderlyId,
    required String familyId,
  }) async {
    final uri = Uri.parse('$_baseUrl/task-submissions');

    debugPrint('📤 submitTask: $taskTitle ($taskId)');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'taskId':     taskId,
        'taskTitle':  taskTitle,
        'elderlyId':  elderlyId,
        'familyId':   familyId,
        'proofImgUrl': null,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ submitTask success');
    } else {
      debugPrint('❌ submitTask error [${response.statusCode}]: ${response.body}');
      throw Exception('Submit failed: ${response.statusCode}');
    }
  }
}
