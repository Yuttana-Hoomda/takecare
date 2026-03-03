
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:takecare/features/elderly_history/models/event_task.dart';

class HistoryService {
  final String url = "http://10.0.2.2:3000/api";

  /// GET /event/get/{familyId}
  /// คืน Map<String, DayData> โดย key คือ "yyyy-MM-dd"
  Future<Map<String, DayData>> getEvents(String familyId) async {
    try {
      final response = await http.get(
        Uri.parse('$url/event/get/$familyId'),
      );

      if (response.statusCode == 200) {
        log('load events success: ${response.body}');
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseEventMap(data);
      } else {
        log('Server Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to fetch events from server");
      }
    } catch (err) {
      throw Exception('Failed to call API: $err');
    }
  }

  /// รูป API :
  /// {
  ///   "2023-10-09": [ { "task": {...}, "isDone": true, "completedAt": "8:05 AM" } ],
  ///   "2023-10-08": [ ... ]
  /// }
  ///
  Map<String, DayData> _parseEventMap(Map<String, dynamic> json) {
    final Map<String, DayData> result = {};
    for (final entry in json.entries) {
      try {
        result[entry.key] = DayData.fromJson(entry.value as List<dynamic>);
      } catch (e) {
        log('Error parsing date ${entry.key}: $e');
      }
    }
    return result;
  }
}