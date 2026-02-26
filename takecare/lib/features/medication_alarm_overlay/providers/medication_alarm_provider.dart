// lib/features/medication_alarm_overlay/providers/medication_alarm_provider.dart

import 'package:flutter/foundation.dart';
import '../models/medication_alarm_model.dart';
import '../services/medication_alarm_service.dart';

enum AlarmActionState { idle, loading, snoozed, completed, error }

class MedicationAlarmProvider extends ChangeNotifier {
  final MedicationAlarmService _service = MedicationAlarmService();

  AlarmActionState _actionState = AlarmActionState.idle;
  String? _capturedPhotoPath;
  String? _errorMessage;

  AlarmActionState get actionState => _actionState;
  String? get capturedPhotoPath => _capturedPhotoPath;
  String? get errorMessage => _errorMessage;

  final MedicationAlarmModel currentAlarm = const MedicationAlarmModel(
    id: '1',
    medicationName: 'Calcium & Vitamin D',
    scheduledTime: '8:00 AM',
    dosage: '1 tablet',
  );

  // ─── เปิดกล้อง ────────────────────────────────────
  Future<void> onDoneTakePhoto() async {
    try {
      _actionState = AlarmActionState.loading;
      _errorMessage = null;
      notifyListeners();

      final path = await _service.takePhoto();

      if (path != null) {
        _capturedPhotoPath = path;
        _actionState = AlarmActionState.completed;
      } else {
        // ผู้ใช้กด cancel
        _actionState = AlarmActionState.idle;
      }
    } catch (e) {
      _errorMessage = 'Cannot open camera: $e';
      _actionState = AlarmActionState.error;
    }

    notifyListeners();
  }

  void onSnooze() {
    _actionState = AlarmActionState.snoozed;
    notifyListeners();
  }

  void reset() {
    _actionState = AlarmActionState.idle;
    _capturedPhotoPath = null;
    _errorMessage = null;
    notifyListeners();
  }
}
