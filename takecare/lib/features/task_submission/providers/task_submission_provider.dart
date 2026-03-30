import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/task_submission_model.dart';
import '../services/task_submission_service.dart';

class TaskSubmissionProvider with ChangeNotifier {
  final TaskSubmissionService _service = TaskSubmissionService();

  bool _isLoading = false;
  String? _errorMessage;
  List<TaskSubmission> _submissions = [];
  TaskSubmission? _latestSubmission;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskSubmission> get submissions => _submissions;
  TaskSubmission? get latestSubmission => _latestSubmission;

  // POST /task-submissions
  Future<bool> submit({
    required String taskId,
    required String elderlyId,
    required String familyId,
    required String displayTitle,
    required String token,
    String? proofImgUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _latestSubmission = await _service.submit(
        taskId: taskId,
        elderlyId: elderlyId,
        familyId: familyId,
        displayTitle: displayTitle,
        token: token,
        proofImgUrl: proofImgUrl,
      );
      _submissions.insert(0, _latestSubmission!);
      return true;
    } catch (e) {
      _errorMessage = 'ไม่สามารถบันทึกงานได้ กรุณาลองใหม่';
      log('submit error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GET /task-submissions?familyId=
  Future<void> loadByFamily({
    required String familyId,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submissions = await _service.getByFamily(
        familyId: familyId,
        token: token,
      );
    } catch (e) {
      _errorMessage = 'ไม่สามารถโหลดข้อมูลได้';
      log('loadByFamily error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}