// lib/features/medication_alarm_overlay/services/medication_alarm_service.dart

// lib/features/medication_alarm_overlay/services/medication_alarm_service.dart

import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';

class MedicationAlarmService {
  final ImagePicker _picker = ImagePicker();

  // ─── Cloudinary config ────────────────────────────────────────
  // ใส่ค่าจาก Cloudinary Dashboard ของคุณ
  static const String _cloudName = 'dyohhlo45';
  static const String _uploadPreset = 'takecare'; // unsigned preset
  // ─────────────────────────────────────────────────────────────

  http.Client _createDevClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (_, __, ___) => true;
    return IOClient(httpClient);
  }

  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return photo?.path;
  }

  Future<String> uploadToCloudinary(String imagePath, String alarmId) async {
    final file = File(imagePath);
    if (!file.existsSync()) throw Exception('Image file not found');

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    // ✅ ใช้ _createDevClient() แทน default client
    final client = _createDevClient();
    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['folder'] = 'medication_proofs'
        ..fields['public_id'] =
            'alarm_${alarmId}_${DateTime.now().millisecondsSinceEpoch}'
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      log('📤 Uploading to Cloudinary...');
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['secure_url'] as String;
        log('✅ Cloudinary upload success: $url');
        return url;
      } else {
        log('❌ Cloudinary error [${response.statusCode}]: ${response.body}');
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<void> saveProofToFirestore({
    required String alarmId,
    required String photoUrl,
    required String token,
  }) async {
    const baseUrl = 'http://10.0.2.2:3000/api';

    final uri = Uri.parse('$baseUrl/tasks/$alarmId');

    log('💾 Saving proof URL to Firestore...');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'photoProofUrl': photoUrl}),
    );

    if (response.statusCode == 200) {
      log('✅ Proof saved to Firestore');
    } else {
      log('❌ Save proof error [${response.statusCode}]: ${response.body}');
      throw Exception('Failed to save proof: ${response.statusCode}');
    }
  }
}
