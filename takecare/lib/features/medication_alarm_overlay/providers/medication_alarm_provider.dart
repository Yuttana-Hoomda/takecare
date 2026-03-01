// lib/features/medication_alarm_overlay/providers/medication_alarm_provider.dart

import 'package:flutter/foundation.dart';
import '../models/medication_alarm_model.dart';
import '../services/medication_alarm_service.dart';

enum AlarmActionState { idle, loading, uploading, snoozed, completed, error }

class MedicationAlarmProvider extends ChangeNotifier {
  final MedicationAlarmService _service;
  final MedicationAlarmModel currentAlarm;
  final String? firebaseToken; // ✅ ส่งมาจากภายนอก เพื่อ save ลง Firestore

  MedicationAlarmProvider({
    required this.currentAlarm,
    this.firebaseToken,
    MedicationAlarmService? service,
  }) : _service = service ?? MedicationAlarmService();

  AlarmActionState _actionState = AlarmActionState.idle;
  String? _capturedPhotoPath;
  String? _uploadedPhotoUrl;
  String? _errorMessage;
  String _statusMessage = '';

  AlarmActionState get actionState => _actionState;
  String? get capturedPhotoPath => _capturedPhotoPath;
  String? get uploadedPhotoUrl => _uploadedPhotoUrl;
  String? get errorMessage => _errorMessage;
  String get statusMessage => _statusMessage;

  // ─── ถ่ายรูป → upload → save ─────────────────────────────────
  Future<void> onDoneTakePhoto() async {
    try {
      // Step 1: ถ่ายรูป
      _setState(AlarmActionState.loading, '📷 กำลังเปิดกล้อง...');

      final path = await _service.takePhoto();
      if (path == null) {
        // ผู้ใช้กด cancel
        _setState(AlarmActionState.idle, '');
        return;
      }

      _capturedPhotoPath = path;

      // Step 2: Upload ไป Cloudinary
      _setState(AlarmActionState.uploading, '📤 กำลังอัปโหลดรูป...');

      final url = await _service.uploadToCloudinary(path, currentAlarm.id);
      _uploadedPhotoUrl = url;

      // Step 3: Save URL ลง Firestore (ถ้ามี token)
      if (firebaseToken != null) {
        _setState(AlarmActionState.uploading, '💾 กำลังบันทึก...');
        await _service.saveProofToFirestore(
          alarmId: currentAlarm.id,
          photoUrl: url,
          token: firebaseToken!,
        );
      }

      _setState(AlarmActionState.completed, '✅ บันทึกสำเร็จ');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AlarmActionState.error, '');
    }
  }

  void onSnooze() {
    _setState(AlarmActionState.snoozed, '');
  }

  void clearError() {
    if (_actionState == AlarmActionState.error) {
      _setState(AlarmActionState.idle, '');
      _errorMessage = null;
    }
  }

  void reset() {
    _capturedPhotoPath = null;
    _uploadedPhotoUrl = null;
    _errorMessage = null;
    _setState(AlarmActionState.idle, '');
  }

  void _setState(AlarmActionState state, String message) {
    _actionState = state;
    _statusMessage = message;
    notifyListeners();
  }
}
