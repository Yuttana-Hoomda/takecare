import 'dart:developer';
import 'package:flutter/cupertino.dart';
import '../services/history_service.dart';
import '../models/event_task.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  bool _isLoading = false;
  String? _errorMessage;

  /// key: "yyyy-MM-dd"
  Map<String, DayData> _eventData = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, DayData> get eventData => _eventData;

  Future<void> getEvents(String familyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventData = await _historyService.getEvents(familyId);
    } catch (e) {
      _errorMessage = 'โหลดข้อมูลล้มเหลว';
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  //สำหรับทดสอบ ui
  void loadMockData(Map<String, DayData> mockData) {
    _eventData = mockData;
    notifyListeners();
  }
  DayData? getDataForDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _eventData[key];
  }
}