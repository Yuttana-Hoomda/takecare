import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:takecare/features/task/models/task_model.dart';

class TaskService {
  //final String url = "http://10.0.2.2:3000/api";
  final String url = Platform.isAndroid //เพื่อรองรับ ios
      ? "http://10.0.2.2:3000/api"
      : "http://localhost:3000/api";

  Future<List<Task>> getTasks(String familyId) async {
    try {
      final response = await http.get(
          Uri.parse('$url/tasks/family/$familyId')
      );

      if (response.statusCode == 200) {
        log('load tasks success: ${response.body}');
        final List<dynamic> data = jsonDecode(response.body);
        final List<Task> tasks = data
            .map((json) => Task.fromJson(json))
            .toList();
        return tasks;
      } else {
        log('Server Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to fetch tasks from server");
      }
    } catch (err) {
      throw Exception('Failed to call API: $err');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$url/tasks',),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201) {
        log('create task succuess: ${jsonDecode(response.body)}');
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to create task. Status: ${response.statusCode}');
      }
    } catch (err) {
      throw Exception('Error communicating with the server: $err');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      if (task.taskId == null || task.taskId!.isEmpty) {
        log('taskId is null or empty: ${task.taskId}');
        throw Exception('taskId is null or empty');
      }
      final response = await http.patch(
        Uri.parse('$url/tasks/${task.taskId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        log('response body: ${response.body}');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Task.fromJson(responseData);
      } else {
        log('Server Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to fetch tasks from server");
      }
    } catch (err) {
      throw Exception('Failed to call API: $err');
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      if (task.taskId == null || task.taskId!.isEmpty) {
        log('taskId is null or empty: ${task.taskId}');
        throw Exception('taskId is null or empty');
      }
      final response = await http.delete(
        Uri.parse('$url/tasks/${task.taskId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        log('delete success: ${response.body}');
      } else {
        log('Server Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to fetch tasks from server");
      }
    } catch (err) {
      throw Exception('Failed to call API: $err');
    }
  }
}