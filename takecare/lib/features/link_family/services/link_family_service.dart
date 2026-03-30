import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:takecare/features/link_family/models/elder_model.dart';
import 'dart:io';

class LinkFamilyService {
  //final String baseUrl = "https://takecare-taupe.vercel.app//api";
  final String baseUrl = Platform.isAndroid
      ? "https://takecare-taupe.vercel.app/api"
      : "https://takecare-taupe.vercel.app/api";

  /// ค้นหา elder จากเบอร์โทร
  Future<ElderModel> searchElderByPhone(String phone, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?phone=$phone'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        log('  searchElderByPhone: ${response.body}');
        final data = jsonDecode(response.body);
        return ElderModel.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw Exception('ไม่พบผู้ใช้งานหมายเลขนี้');
      } else {
        log('❌ searchElderByPhone [${response.statusCode}]: ${response.body}');
        throw Exception('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      log('❌ searchElderByPhone error: $e');
      rethrow;
    }
  }

  /// ยืนยัน link caregiver เข้า family ของ elder
  Future<void> linkFamily(String elderUid, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/families/link'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'elderUid': elderUid}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('  linkFamily success: ${response.body}');
      } else {
        log('❌ linkFamily [${response.statusCode}]: ${response.body}');
        throw Exception('ไม่สามารถเชื่อมต่อครอบครัวได้ กรุณาลองใหม่');
      }
    } catch (e) {
      log('❌ linkFamily error: $e');
      rethrow;
    }
  }
}
