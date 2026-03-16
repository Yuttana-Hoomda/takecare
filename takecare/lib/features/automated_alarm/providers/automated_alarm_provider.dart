import 'package:flutter/foundation.dart';
import '../models/automated_alarm_model.dart';
import '../services/automated_alarm_service.dart';

enum AlarmActionState { idle, loading, submitting, snoozed, completed, error }

class AutomatedAlarmProvider extends ChangeNotifier {
  final AutomatedAlarmService _service;
  final AutomatedAlarmModel currentAlarm;
  final String elderlyId;
  final String familyId;

  AutomatedAlarmProvider({
    required this.currentAlarm,
    required this.elderlyId,
    required this.familyId,
    AutomatedAlarmService? service,
  }) : _service = service ?? AutomatedAlarmService();

  AlarmActionState _actionState = AlarmActionState.idle;
  String? _capturedPhotoPath;
  String? _errorMessage;
  String _statusMessage = '';

  AlarmActionState get actionState => _actionState;
  String? get capturedPhotoPath => _capturedPhotoPath;
  String? get errorMessage => _errorMessage;
  String get statusMessage => _statusMessage;

  Future<void> onDoneTakePhoto() async {
    try {
      // Step 1: ถ่ายรูป
      _setState(AlarmActionState.loading, 'กำลังเปิดกล้อง...');

      final path = await _service.takePhoto();
      if (path == null) {
        _setState(AlarmActionState.idle, '');
        return;
      }
      _capturedPhotoPath = path;

      // Step 2: Submit task
      _setState(AlarmActionState.submitting, 'กำลังบันทึก...');
      await _service.submitTask(
        taskId:    currentAlarm.id,
        taskTitle: currentAlarm.title,
        elderlyId: elderlyId,
        familyId:  familyId,
      );

      _setState(AlarmActionState.completed, '');
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
      _actionState = AlarmActionState.idle;
      _errorMessage = null;
      _statusMessage = '';
      notifyListeners();
    }
  }

  void _setState(AlarmActionState state, String message) {
    _actionState = state;
    _statusMessage = message;
    notifyListeners();
  }
}
