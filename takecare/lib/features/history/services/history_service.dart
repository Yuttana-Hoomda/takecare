import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_calendar_model.dart';
import '../models/event_model.dart';

class HistoryService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  /// GET /event-calendar?month=03&year=2026
  Future<List<EventCalendar>> getEventCalendar({
    required int month,
    required int year,
  }) async {
    final monthStr = month.toString().padLeft(2, '0');
    final uri = Uri.parse('$_baseUrl/event-calendar').replace(
      queryParameters: {'month': monthStr, 'year': year.toString()},
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EventCalendar.fromJson(e)).toList();
    }
    throw Exception('Failed to load event calendar: ${response.statusCode}');
  }

  /// GET /event?date=2026-03-15
  Future<List<Event>> getEventsByDate(String date, String familyId) async {
    final uri = Uri.parse('$_baseUrl/event').replace(
      queryParameters: {'date': date, 'familyId': familyId},
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events: ${response.statusCode}');
  }
}