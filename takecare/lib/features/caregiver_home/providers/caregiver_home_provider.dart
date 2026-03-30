import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/daily_summary_model.dart';
import '../services/caregiver_home_service.dart';

class CaregiverHomeProvider extends ChangeNotifier {
  final CaregiverHomeService _service = CaregiverHomeService();

  DailySummary _summary = DailySummary.empty();
  List<RecentEventItem> _recentEvents = [];
  ElderInfo _elderInfo = ElderInfo.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DailySummary get summary => _summary;
  List<RecentEventItem> get recentEvents => _recentEvents;
  ElderInfo get elderInfo => _elderInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get todayStr {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayData(String familyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ ยิง 3 requests พร้อมกันเลย ไม่ต้อง await ทีละอัน
      final results = await Future.wait([
        _service.getDailySummary(familyId: familyId, date: todayStr),
        _service.getRecentEvents(familyId: familyId, date: todayStr),
        _service.getElderInfo(familyId: familyId),
      ]);

      _summary      = results[0] as DailySummary;
      _recentEvents = results[1] as List<RecentEventItem>;
      _elderInfo    = results[2] as ElderInfo;
    } catch (e) {
      _errorMessage = 'โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่';
      log('CaregiverHomeProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
