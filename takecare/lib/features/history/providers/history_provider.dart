import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/event_calendar_model.dart';
import '../models/event_model.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  // --- Calendar layer (dot status) ---
  // key: "yyyy-MM-dd"
  Map<String, EventCalendar> _calendarData = {};
  bool _isCalendarLoading = false;

  // --- Daily events ---
  List<Event> _dayEvents = [];
  bool _isDayLoading = false;
  String? _loadedDate; // วันที่โหลดล่าสุด (cache ไม่ fetch ซ้ำ)

  String? _errorMessage;

  Map<String, EventCalendar> get calendarData => _calendarData;
  List<Event> get dayEvents => _dayEvents;
  bool get isCalendarLoading => _isCalendarLoading;
  bool get isDayLoading => _isDayLoading;
  String? get errorMessage => _errorMessage;

  /// โหลด dot status ทั้งเดือน — เรียกเมื่อ scroll ไปเดือนใหม่
  Future<void> loadMonth({required int month, required int year}) async {
    // ถ้าเดือนนี้มีข้อมูลแล้วไม่ต้อง fetch ซ้ำ
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    final alreadyLoaded = _calendarData.keys.any((k) => k.startsWith(monthKey));
    if (alreadyLoaded) return;

    _isCalendarLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _service.getEventCalendar(month: month, year: year);
      for (final ec in list) {
        _calendarData[ec.date] = ec;
      }
    } catch (e) {
      _errorMessage = 'โหลดปฏิทินล้มเหลว';
      log(e.toString());
    } finally {
      _isCalendarLoading = false;
      notifyListeners();
    }
  }

  /// โหลด event list ของวันที่เลือก
  Future<void> loadDay(String date, String familyId) async {
    if (_loadedDate == date) return; // cache

    _isDayLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dayEvents = await _service.getEventsByDate(date, familyId);
      _loadedDate = date;
    } catch (e) {
      _errorMessage = 'โหลดรายการล้มเหลว';
      _dayEvents = [];
      log(e.toString());
    } finally {
      _isDayLoading = false;
      notifyListeners();
    }
  }

  /// ดึง DayStatus สำหรับแสดง dot
  DayStatus? getStatusForDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _calendarData[key]?.status;
  }

  /// clear cache วันที่ (ใช้เมื่อ refresh)
  void clearDayCache() {
    _loadedDate = null;
    _dayEvents = [];
    notifyListeners();
  }
}