import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:takecare/features/automated_alarm/services/alarm_scheduler.dart';
import 'package:takecare/features/task/services/task_service.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Task>? _tasks = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Task>? get tasks => _tasks;

  // ✅ getTasks: schedule ครั้งแรกเท่านั้น (guard ใน AlarmScheduler)
  Future<void> getTasks(String familyId, {required String elderlyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(familyId);
      await AlarmScheduler.instance.scheduleTasks(
        _tasks ?? [],
        elderlyId: elderlyId,
        familyId: familyId,
      );
    } catch (e) {
      _errorMessage = 'load tasks failed.';
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ create: rescheduleAll เพื่อรวม task ใหม่เข้าไป
  Future<void> createTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTask = await _taskService.createTask(task);
      _tasks = _tasks == null ? [createdTask] : [createdTask, ..._tasks!];

      await AlarmScheduler.instance.rescheduleAll(
        _tasks!,
        elderlyId: AlarmScheduler.instance.elderlyId,
        familyId: task.familyId,
      );
    } catch (err) {
      _errorMessage = 'Failed to create task';
      log('Error in TaskProvider.createTask: $err');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _taskService.updateTask(task);
      if (_tasks != null) {
        final index = _tasks!.indexWhere((t) => t.taskId == task.taskId);
        if (index != -1) _tasks![index] = updatedTask;
      }

      await AlarmScheduler.instance.rescheduleAll(
        _tasks ?? [],
        elderlyId: AlarmScheduler.instance.elderlyId,
        familyId: task.familyId,
      );
    } catch (err) {
      _errorMessage = 'Failed to update task';
      log('Error in TaskProvider.updateTask: $err');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskService.deleteTask(task);
      _tasks?.removeWhere((t) => t.taskId == task.taskId);

      // cancel notification เฉพาะ task ที่ลบ ไม่ต้อง reschedule ทั้งหมด
      if (task.taskId != null) {
        await AlarmScheduler.instance.cancelTask(task.taskId!);
      }
    } catch (err) {
      _errorMessage = 'Failed to delete task';
      log('Error in TaskProvider.deleteTask: $err');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
