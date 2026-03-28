import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/event_calendar_model.dart';
import '../models/event_model.dart';
import 'dart:io';

class HistoryService {
  final String baseUrl = Platform.isAndroid
      ? "http://10.0.2.2:3000/api"
      : "http://localhost:3000/api";

  Future<List<EventCalendar>> getEventCalendar({
    required int month,
    required int year,
    required String familyId,
  }) async {
    final monthStr = month.toString().padLeft(2, '0');
    
    // ใช้ lowercase ทั้งหมดตามมาตรฐาน Backend (event-calendar และ month)
    final uri = Uri.parse('$baseUrl/event-calendar').replace(
      queryParameters: {
        'month': monthStr,
        'year': year.toString(),
        'familyId': familyId,
      },
    );
    
    log("📡 [CALENDAR REQUEST]: $uri");

    try {
      final response = await http.get(uri);
      log("📥 [CALENDAR RESPONSE]: ${response.body}");
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EventCalendar.fromJson(e)).toList();
      }
    } catch (e) {
      log("❌ [CALENDAR EXCEPTION]: $e");
    }
    return [];
  }

  Future<List<Event>> getEventsByDate(String date, String familyId) async {
    final uri = Uri.parse('$baseUrl/event').replace(
      queryParameters: {'date': date, 'familyId': familyId},
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }
}