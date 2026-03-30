import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/daily_summary_model.dart';
import '../services/caregiver_home_service.dart';

class CaregiverHomeProvider extends ChangeNotifier {
  final CaregiverHomeService _service = CaregiverHomeService();

  DailySummary _summary = DailySummary.empty();
  List<RecentEventItem> _recentEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  DailySummary get summary            => _summary;
  List<RecentEventItem> get recentEvents => _recentEvents;
  bool get isLoading                  => _isLoading;
  String? get errorMessage            => _errorMessage;

  // today in Bangkok timezone (yyyy-MM-dd)
  String get todayStr {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayData(String familyId) async {
    _isLoading = true;
    _errorMessage = null; // [FIX 5] clear error ก่อนโหลดใหม่
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getDailySummary(familyId: familyId, date: todayStr),
        _service.getRecentEvents(familyId: familyId, date: todayStr),
      ]);

      _summary      = results[0] as DailySummary;
      _recentEvents = results[1] as List<RecentEventItem>;
    } catch (e) {
      // [FIX 5] เก็บ error message ให้ UI แสดงได้
      _errorMessage = 'โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่';
      log('CaregiverHomeProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
