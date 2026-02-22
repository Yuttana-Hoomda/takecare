import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:takecare/features/task/services/task_service.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier{
  final TaskService _taskService = TaskService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Task>? _tasks = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Task>? get tasks => _tasks;

  Future<void> getTasks(String familyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(familyId);
    } catch (e) {
      _errorMessage = "load tasks failed.";
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

    try{
      final createdTask = await _taskService.createTask(task);

      if (_tasks != null) {
        _tasks!.insert(0, createdTask);
      } else {
        _tasks = [task];
      }
    } catch(err) {
      _errorMessage = 'Failed to create task';
      log("Error in TaskProvider.createTask: ${err.toString()}");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}