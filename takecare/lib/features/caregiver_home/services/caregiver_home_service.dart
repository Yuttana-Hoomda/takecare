import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/daily_summary_model.dart';

class CaregiverHomeService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // GET /api/home/summary?familyId=xxx&date=2026-03-28
  Future<DailySummary> getDailySummary({
    required String familyId,
    required String date,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/home/summary',
    ).replace(queryParameters: {'familyId': familyId, 'date': date});

    final response = await http.get(uri);
    log('RAW summary response: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return DailySummary.fromJson(body); // ✅ no ['data'] needed
    } else {
      throw Exception('getDailySummary failed: ${response.statusCode}');
    }
  }

  // GET /api/home/recent-events?familyId=xxx&date=2026-03-28
  Future<List<RecentEventItem>> getRecentEvents({
    required String familyId,
    required String date,
  }) async {
    final uri = Uri.parse('$_baseUrl/home/recent-events')
        .replace(queryParameters: {'familyId': familyId, 'date': date});

    final response = await http.get(uri);
    log('RAW events response: ${response.body}'); // 👈 add this

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RecentEventItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('getRecentEvents failed: ${response.statusCode}');
    }
  }
}
