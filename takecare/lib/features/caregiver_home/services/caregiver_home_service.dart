import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_summary_model.dart';

class CaregiverHomeService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<DailySummary> getDailySummary({
    required String familyId,
    required String date,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/home/summary',
    ).replace(queryParameters: {'familyId': familyId, 'date': date});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return DailySummary.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('getDailySummary failed: ${response.statusCode}');
    }
  }

  Future<List<RecentEventItem>> getRecentEvents({
    required String familyId,
    required String date,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/home/recent-events',
    ).replace(queryParameters: {'familyId': familyId, 'date': date});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RecentEventItem.fromJson(e)).toList();
    } else {
      throw Exception('getRecentEvents failed: ${response.statusCode}');
    }
  }

  // ✅ ย้ายเข้ามาใน class
  Future<ElderInfo> getElderInfo({required String familyId}) async {
    final uri = Uri.parse(
      '$_baseUrl/families/elder-info',
    ).replace(queryParameters: {'familyId': familyId});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ElderInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('getElderInfo failed: ${response.statusCode}');
    }
  }
}
