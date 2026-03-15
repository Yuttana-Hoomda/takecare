import 'package:flutter/foundation.dart';
import '../models/automated_alarm_model.dart';
import '../services/automated_alarm_service.dart';

enum AlarmActionState { idle, loading, snoozed, completed, error }

class AutomatedAlarmProvider extends ChangeNotifier {
  final AutomatedAlarmService _service;
  final AutomatedAlarmModel currentAlarm;

  AutomatedAlarmProvider({
    required this.currentAlarm,
    AutomatedAlarmService? service,
  }) : _service = service ?? AutomatedAlarmService();

  AlarmActionState _actionState = AlarmActionState.idle;
  String? _capturedPhotoPath;
  String? _errorMessage;

  AlarmActionState get actionState => _actionState;
  String? get capturedPhotoPath => _capturedPhotoPath;
  String? get errorMessage => _errorMessage;

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
        _actionState = AlarmActionState.idle;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _actionState = AlarmActionState.error;
    }
    notifyListeners();
  }

  void onSnooze() {
    _actionState = AlarmActionState.snoozed;
    notifyListeners();
  }

  void clearError() {
    if (_actionState == AlarmActionState.error) {
      _actionState = AlarmActionState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void reset() {
    _capturedPhotoPath = null;
    _errorMessage = null;
    _actionState = AlarmActionState.idle;
    notifyListeners();
  }
}
