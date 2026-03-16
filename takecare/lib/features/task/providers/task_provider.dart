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

  Future<void> getTasks(String familyId, {required String elderlyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(familyId);
      // ✅ ส่ง elderlyId และ familyId ไปด้วย
      AlarmScheduler.instance.scheduleTasks(
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

  Future<void> createTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTask = await _taskService.createTask(task);
      if (_tasks != null) {
        _tasks!.insert(0, createdTask);
      } else {
        _tasks = [createdTask];
      }
      AlarmScheduler.instance.scheduleTasks(
        _tasks ?? [],
        elderlyId: AlarmScheduler.instance.elderlyId,
        familyId: task.familyId,
      );
    } catch (err) {
      _errorMessage = 'Failed to create task';
      log('Error in TaskProvider.createTask: ${err.toString()}');
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
      AlarmScheduler.instance.scheduleTasks(
        _tasks ?? [],
        elderlyId: AlarmScheduler.instance.elderlyId,
        familyId: task.familyId,
      );
    } catch (err) {
      _errorMessage = 'Failed to update task';
      log('Error in TaskProvider.update: ${err.toString()}');
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
      AlarmScheduler.instance.scheduleTasks(
        _tasks ?? [],
        elderlyId: AlarmScheduler.instance.elderlyId,
        familyId: task.familyId,
      );
    } catch (err) {
      _errorMessage = 'Failed to delete task';
      log('Error in TaskProvider.delete: ${err.toString()}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
