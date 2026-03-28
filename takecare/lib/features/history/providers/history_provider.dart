import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/event_calendar_model.dart';
import '../models/event_model.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  // key: "yyyy-MM-dd"
  final Map<String, EventCalendar> _calendarData = {};
  bool _isCalendarLoading = false;

  List<Event> _dayEvents = [];
  bool _isDayLoading = false;
  String? _loadedDate;

  String? _errorMessage;

  Map<String, EventCalendar> get calendarData => _calendarData;
  List<Event> get dayEvents => _dayEvents;
  bool get isCalendarLoading => _isCalendarLoading;
  bool get isDayLoading => _isDayLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMonth({
    required int month,
    required int year,
    required String familyId,
    bool force = false,
  }) async {
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    
    // ถ้าไม่บังคับโหลด และเคยโหลดเดือนนี้ไปแล้ว ให้ข้าม
    if (!force) {
      final alreadyLoaded = _calendarData.keys.any((k) => k.startsWith(monthKey));
      if (alreadyLoaded) return;
    }

    _isCalendarLoading = true;
    notifyListeners();

    try {
      final list = await _service.getEventCalendar(month: month, year: year, familyId: familyId);
      
      // ถ้า force ให้เคลียร์ข้อมูลเก่าของเดือนนั้นออกก่อน
      if (force) {
        _calendarData.removeWhere((key, value) => key.startsWith(monthKey));
      }

      for (final ec in list) {
        _calendarData[ec.date] = ec;
      }
    } catch (e) {
      log("❌ LoadMonth Error: $e");
    } finally {
      _isCalendarLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDay(String date, String familyId, {bool force = false}) async {
    // ถ้าไม่บังคับโหลด และเป็นวันที่เดิม ให้ข้าม
    if (!force && _loadedDate == date) return;

    _isDayLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dayEvents = await _service.getEventsByDate(date, familyId);
      _loadedDate = date;
      
      // อัปเดตข้อมูลจุดสี (Dot) ทันทีจากข้อมูลรายวันที่เพิ่งโหลดมา
      if (_dayEvents.isNotEmpty) {
        final completed = _dayEvents.where((e) => e.isCompleted || e.status == 'completed').length;
        final missed = _dayEvents.where((e) => e.status == 'missed').length;
        
        _calendarData[date] = EventCalendar(
          date: date,
          familyId: familyId,
          completedCount: completed,
          missedCount: missed,
          totalCount: _dayEvents.length,
        );
      } else {
        // ถ้าโหลดมาแล้วไม่มีงาน ให้เอาจุดออก (ถ้ามี)
        _calendarData.remove(date);
      }
    } catch (e) {
      _errorMessage = 'โหลดรายการล้มเหลว';
      _dayEvents = [];
      log(e.toString());
    } finally {
      _isDayLoading = false;
      notifyListeners();
    }
  }

  DayStatus? getStatusForDate(DateTime date) {
    final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final data = _calendarData[key];
    if (data == null) return null;
    return data.status;
  }

  void clearDayCache() {
    _loadedDate = null;
    _dayEvents = [];
    notifyListeners();
  }
}